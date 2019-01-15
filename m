Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A83C8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 03:24:59 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t2so1403594pfj.15
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 00:24:59 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j66si2792355pfb.182.2019.01.15.00.24.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 00:24:58 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0F8IpWh119555
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 03:24:57 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2q18tvq36w-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 03:24:57 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 15 Jan 2019 08:24:55 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: Re: [PATCH v11 00/26] Speculative page faults
References: <8b0b2c05-89f8-8002-2dce-fa7004907e78@codeaurora.org>
 <5a24109c-7460-4a8e-a439-d2f2646568e6@codeaurora.org>
Date: Tue, 15 Jan 2019 09:24:50 +0100
MIME-Version: 1.0
In-Reply-To: <5a24109c-7460-4a8e-a439-d2f2646568e6@codeaurora.org>
Content-Type: multipart/mixed;
 boundary="------------1BE06C0E8FE429C08B5EE0B5"
Content-Language: en-US
Message-Id: <9ae5496f-7a51-e7b7-0061-5b68354a7945@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: Linux-MM <linux-mm@kvack.org>, charante@codeaurora.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

This is a multi-part message in MIME format.
--------------1BE06C0E8FE429C08B5EE0B5
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit

Le 14/01/2019 à 14:19, Vinayak Menon a écrit :
> On 1/11/2019 9:13 PM, Vinayak Menon wrote:
>> Hi Laurent,
>>
>> We are observing an issue with speculative page fault with the following test code on ARM64 (4.14 kernel, 8 cores).
> 
> 
> With the patch below, we don't hit the issue.
> 
> From: Vinayak Menon <vinmenon@codeaurora.org>
> Date: Mon, 14 Jan 2019 16:06:34 +0530
> Subject: [PATCH] mm: flush stale tlb entries on speculative write fault
> 
> It is observed that the following scenario results in
> threads A and B of process 1 blocking on pthread_mutex_lock
> forever after few iterations.
> 
> CPU 1                   CPU 2                    CPU 3
> Process 1,              Process 1,               Process 1,
> Thread A                Thread B                 Thread C
> 
> while (1) {             while (1) {              while(1) {
> pthread_mutex_lock(l)   pthread_mutex_lock(l)    fork
> pthread_mutex_unlock(l) pthread_mutex_unlock(l)  }
> }                       }
> 
> When from thread C, copy_one_pte write-protects the parent pte
> (of lock l), stale tlb entries can exist with write permissions
> on one of the CPUs at least. This can create a problem if one
> of the threads A or B hits the write fault. Though dup_mmap calls
> flush_tlb_mm after copy_page_range, since speculative page fault
> does not take mmap_sem it can proceed further fixing a fault soon
> after CPU 3 does ptep_set_wrprotect. But the CPU with stale tlb
> entry can still modify old_page even after it is copied to
> new_page by wp_page_copy, thus causing a corruption.

Nice catch and thanks for your investigation!

There is a real synchronization issue here between copy_page_range() and 
the speculative page fault handler. I didn't get it on PowerVM since the 
TLB are flushed when arch_exit_lazy_mode() is called in 
copy_page_range() but now, I can get it when running on x86_64.

> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
> ---
>   mm/memory.c | 7 +++++++
>   1 file changed, 7 insertions(+)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 52080e4..1ea168ff 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -4507,6 +4507,13 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>                  return VM_FAULT_RETRY;
>          }
> 
> +       /*
> +        * Discard tlb entries created before ptep_set_wrprotect
> +        * in copy_one_pte
> +        */
> +       if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))
> +               flush_tlb_page(vmf.vma, address);
> +
>          mem_cgroup_oom_enable();
>          ret = handle_pte_fault(&vmf);
>          mem_cgroup_oom_disable();

Your patch is fixing the race but I'm wondering about the cost of these 
tlb flushes. Here we are flushing on a per page basis (architecture like 
x86_64 are smarter and flush more pages) but there is a request to flush 
a range of tlb entries each time a cow page is newly touched. I think 
there could be some bad impact here.

Another option would be to flush the range in copy_pte_range() before 
unlocking the page table lock. This will flush entries flush_tlb_mm() 
would later handle in dup_mmap() but that will be called once per fork 
per cow VMA.

I tried the attached patch which seems to fix the issue on x86_64. Could 
you please give it a try on arm64 ?

Thanks,
Laurent.


--------------1BE06C0E8FE429C08B5EE0B5
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="0001-mm-flush-TLB-once-pages-are-copied-when-SPF-is-on.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename*0="0001-mm-flush-TLB-once-pages-are-copied-when-SPF-is-on.patch"

RnJvbSA5ODQ3MzM4MTg3YzVjN2UyZDM4N2QxNDc2NTQ1MmQwMGZhNjA5ODFlIE1vbiBTZXAg
MTcgMDA6MDA6MDAgMjAwMQpGcm9tOiBMYXVyZW50IER1Zm91ciA8bGR1Zm91ckBsaW51eC52
bmV0LmlibS5jb20+CkRhdGU6IE1vbiwgMTQgSmFuIDIwMTkgMTg6MzU6MzkgKzAxMDAKU3Vi
amVjdDogW1BBVENIXSBtbTogZmx1c2ggVExCIG9uY2UgcGFnZXMgYXJlIGNvcGllZCB3aGVu
IFNQRiBpcyBvbgoKVmluYXlhayBNZW5vbiByZXBvcnRlZCB0aGF0IHRoZSBmb2xsb3dpbmcg
c2NlbmFyaW8gcmVzdWx0cyBpbgp0aHJlYWRzIEEgYW5kIEIgb2YgcHJvY2VzcyAxIGJsb2Nr
aW5nIG9uIHB0aHJlYWRfbXV0ZXhfbG9jawpmb3JldmVyIGFmdGVyIGZldyBpdGVyYXRpb25z
LgoKQ1BVIDEgICAgICAgICAgICAgICAgICAgQ1BVIDIgICAgICAgICAgICAgICAgICAgIENQ
VSAzClByb2Nlc3MgMSwgICAgICAgICAgICAgIFByb2Nlc3MgMSwgICAgICAgICAgICAgICBQ
cm9jZXNzIDEsClRocmVhZCBBICAgICAgICAgICAgICAgIFRocmVhZCBCICAgICAgICAgICAg
ICAgICBUaHJlYWQgQwoKd2hpbGUgKDEpIHsgICAgICAgICAgICAgd2hpbGUgKDEpIHsgICAg
ICAgICAgICAgIHdoaWxlKDEpIHsKcHRocmVhZF9tdXRleF9sb2NrKGwpICAgcHRocmVhZF9t
dXRleF9sb2NrKGwpICAgIGZvcmsKcHRocmVhZF9tdXRleF91bmxvY2sobCkgcHRocmVhZF9t
dXRleF91bmxvY2sobCkgIH0KfSAgICAgICAgICAgICAgICAgICAgICAgfQoKV2hlbiBmcm9t
IHRocmVhZCBDLCBjb3B5X29uZV9wdGUgd3JpdGUtcHJvdGVjdHMgdGhlIHBhcmVudCBwdGUK
KG9mIGxvY2sgbCksIHN0YWxlIHRsYiBlbnRyaWVzIGNhbiBleGlzdCB3aXRoIHdyaXRlIHBl
cm1pc3Npb25zCm9uIG9uZSBvZiB0aGUgQ1BVcyBhdCBsZWFzdC4gVGhpcyBjYW4gY3JlYXRl
IGEgcHJvYmxlbSBpZiBvbmUKb2YgdGhlIHRocmVhZHMgQSBvciBCIGhpdHMgdGhlIHdyaXRl
IGZhdWx0LiBUaG91Z2ggZHVwX21tYXAgY2FsbHMKZmx1c2hfdGxiX21tIGFmdGVyIGNvcHlf
cGFnZV9yYW5nZSwgc2luY2Ugc3BlY3VsYXRpdmUgcGFnZSBmYXVsdApkb2VzIG5vdCB0YWtl
IG1tYXBfc2VtIGl0IGNhbiBwcm9jZWVkIGZ1cnRoZXIgZml4aW5nIGEgZmF1bHQgc29vbgph
ZnRlciBDUFUgMyBkb2VzIHB0ZXBfc2V0X3dycHJvdGVjdC4gQnV0IHRoZSBDUFUgd2l0aCBz
dGFsZSB0bGIKZW50cnkgY2FuIHN0aWxsIG1vZGlmeSBvbGRfcGFnZSBldmVuIGFmdGVyIGl0
IGlzIGNvcGllZCB0bwpuZXdfcGFnZSBieSB3cF9wYWdlX2NvcHksIHRodXMgY2F1c2luZyBh
IGNvcnJ1cHRpb24uCgpSZXBvcnRlZC1ieTogVmluYXlhayBNZW5vbiA8dmlubWVub25AY29k
ZWF1cm9yYS5vcmc+ClNpZ25lZC1vZmYtYnk6IExhdXJlbnQgRHVmb3VyIDxsZHVmb3VyQGxp
bnV4LnZuZXQuaWJtLmNvbT4KLS0tCiBtbS9tZW1vcnkuYyB8IDkgKysrKysrKysrCiAxIGZp
bGUgY2hhbmdlZCwgOSBpbnNlcnRpb25zKCspCgpkaWZmIC0tZ2l0IGEvbW0vbWVtb3J5LmMg
Yi9tbS9tZW1vcnkuYwppbmRleCA0OGUxY2YwYTU0ZWYuLmI3NTAxMjk0ZTBhMCAxMDA2NDQK
LS0tIGEvbW0vbWVtb3J5LmMKKysrIGIvbW0vbWVtb3J5LmMKQEAgLTExMTIsNiArMTExMiwx
NSBAQCBzdGF0aWMgaW50IGNvcHlfcHRlX3JhbmdlKHN0cnVjdCBtbV9zdHJ1Y3QgKmRzdF9t
bSwgc3RydWN0IG1tX3N0cnVjdCAqc3JjX21tLAogCX0gd2hpbGUgKGRzdF9wdGUrKywgc3Jj
X3B0ZSsrLCBhZGRyICs9IFBBR0VfU0laRSwgYWRkciAhPSBlbmQpOwogCiAJYXJjaF9sZWF2
ZV9sYXp5X21tdV9tb2RlKCk7CisKKwkvKgorCSAqIFByZXZlbnQgdGhlIHBhZ2UgZmF1bHQg
aGFuZGxlciB0byBjb3B5IHRoZSBwYWdlIHdoaWxlIHN0YWxlIHRsYiBlbnRyeQorCSAqIGFy
ZSBzdGlsbCBub3QgZmx1c2hlZC4KKwkgKi8KKwlpZiAoSVNfRU5BQkxFRChDT05GSUdfU1BF
Q1VMQVRJVkVfUEFHRV9GQVVMVCkgJiYKKwkgICAgaXNfY293X21hcHBpbmcodm1hLT52bV9m
bGFncykpCisJCWZsdXNoX3RsYl9yYW5nZSh2bWEsIGFkZHIsIGVuZCk7CisKIAlzcGluX3Vu
bG9jayhzcmNfcHRsKTsKIAlwdGVfdW5tYXAob3JpZ19zcmNfcHRlKTsKIAlhZGRfbW1fcnNz
X3ZlYyhkc3RfbW0sIHJzcyk7Ci0tIAoyLjIwLjEKCg==
--------------1BE06C0E8FE429C08B5EE0B5--
