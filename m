Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E38E8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 11:24:24 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n50so12947675qtb.9
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 08:24:24 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u184si800434qkc.31.2019.01.18.08.24.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 08:24:23 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0IGNlLc028535
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 11:24:22 -0500
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2q3gexcysu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 11:24:22 -0500
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 18 Jan 2019 16:24:20 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: Re: [PATCH v11 00/26] Speculative page faults
References: <8b0b2c05-89f8-8002-2dce-fa7004907e78@codeaurora.org>
 <5a24109c-7460-4a8e-a439-d2f2646568e6@codeaurora.org>
 <9ae5496f-7a51-e7b7-0061-5b68354a7945@linux.vnet.ibm.com>
 <e104a6dc-931b-944c-9555-dc1c001a57e0@codeaurora.org>
 <5C40A48F.6070306@huawei.com>
Date: Fri, 18 Jan 2019 17:24:16 +0100
MIME-Version: 1.0
In-Reply-To: <5C40A48F.6070306@huawei.com>
Content-Type: multipart/mixed;
 boundary="------------A64C24F948C10252E9481302"
Content-Language: en-US
Message-Id: <8bfaf41b-6d88-c0de-35c0-1c41db7a691e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>, Vinayak Menon <vinmenon@codeaurora.org>
Cc: Linux-MM <linux-mm@kvack.org>, charante@codeaurora.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

This is a multi-part message in MIME format.
--------------A64C24F948C10252E9481302
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit

Le 17/01/2019 à 16:51, zhong jiang a écrit :
> On 2019/1/16 19:41, Vinayak Menon wrote:
>> On 1/15/2019 1:54 PM, Laurent Dufour wrote:
>>> Le 14/01/2019 à 14:19, Vinayak Menon a écrit :
>>>> On 1/11/2019 9:13 PM, Vinayak Menon wrote:
>>>>> Hi Laurent,
>>>>>
>>>>> We are observing an issue with speculative page fault with the following test code on ARM64 (4.14 kernel, 8 cores).
>>>>
>>>> With the patch below, we don't hit the issue.
>>>>
>>>> From: Vinayak Menon <vinmenon@codeaurora.org>
>>>> Date: Mon, 14 Jan 2019 16:06:34 +0530
>>>> Subject: [PATCH] mm: flush stale tlb entries on speculative write fault
>>>>
>>>> It is observed that the following scenario results in
>>>> threads A and B of process 1 blocking on pthread_mutex_lock
>>>> forever after few iterations.
>>>>
>>>> CPU 1                   CPU 2                    CPU 3
>>>> Process 1,              Process 1,               Process 1,
>>>> Thread A                Thread B                 Thread C
>>>>
>>>> while (1) {             while (1) {              while(1) {
>>>> pthread_mutex_lock(l)   pthread_mutex_lock(l)    fork
>>>> pthread_mutex_unlock(l) pthread_mutex_unlock(l)  }
>>>> }                       }
>>>>
>>>> When from thread C, copy_one_pte write-protects the parent pte
>>>> (of lock l), stale tlb entries can exist with write permissions
>>>> on one of the CPUs at least. This can create a problem if one
>>>> of the threads A or B hits the write fault. Though dup_mmap calls
>>>> flush_tlb_mm after copy_page_range, since speculative page fault
>>>> does not take mmap_sem it can proceed further fixing a fault soon
>>>> after CPU 3 does ptep_set_wrprotect. But the CPU with stale tlb
>>>> entry can still modify old_page even after it is copied to
>>>> new_page by wp_page_copy, thus causing a corruption.
>>> Nice catch and thanks for your investigation!
>>>
>>> There is a real synchronization issue here between copy_page_range() and the speculative page fault handler. I didn't get it on PowerVM since the TLB are flushed when arch_exit_lazy_mode() is called in copy_page_range() but now, I can get it when running on x86_64.
>>>
>>>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>>>> ---
>>>>    mm/memory.c | 7 +++++++
>>>>    1 file changed, 7 insertions(+)
>>>>
>>>> diff --git a/mm/memory.c b/mm/memory.c
>>>> index 52080e4..1ea168ff 100644
>>>> --- a/mm/memory.c
>>>> +++ b/mm/memory.c
>>>> @@ -4507,6 +4507,13 @@ int __handle_speculative_fault(struct mm_struct *mm, unsigned long address,
>>>>                   return VM_FAULT_RETRY;
>>>>           }
>>>>
>>>> +       /*
>>>> +        * Discard tlb entries created before ptep_set_wrprotect
>>>> +        * in copy_one_pte
>>>> +        */
>>>> +       if (flags & FAULT_FLAG_WRITE && !pte_write(vmf.orig_pte))
>>>> +               flush_tlb_page(vmf.vma, address);
>>>> +
>>>>           mem_cgroup_oom_enable();
>>>>           ret = handle_pte_fault(&vmf);
>>>>           mem_cgroup_oom_disable();
>>> Your patch is fixing the race but I'm wondering about the cost of these tlb flushes. Here we are flushing on a per page basis (architecture like x86_64 are smarter and flush more pages) but there is a request to flush a range of tlb entries each time a cow page is newly touched. I think there could be some bad impact here.
>>>
>>> Another option would be to flush the range in copy_pte_range() before unlocking the page table lock. This will flush entries flush_tlb_mm() would later handle in dup_mmap() but that will be called once per fork per cow VMA.
>>
>> But wouldn't this cause an unnecessary impact if most of the COW pages remain untouched (which I assume would be the usual case) and thus do not create a fault ?
>>
>>
>>> I tried the attached patch which seems to fix the issue on x86_64. Could you please give it a try on arm64 ?
>>>
>> Your patch works fine on arm64 with a minor change. Thanks Laurent.
> Hi, Vinayak and Laurent
> 
> I think the below change will impact the performance significantly. Becuase most of process has many
> vmas with cow flags. Flush the tlb in advance is not the better way to avoid the issue and it will
> call the flush_tlb_mm  later.
> 
> I think we can try the following way to do.
> 
> vm_write_begin(vma)
> copy_pte_range
> vm_write_end(vma)
> 
> The speculative page fault will return to grap the mmap_sem to run the nromal path.
> Any thought?

Here is a new version of the patch fixing this issue. There is no 
additional TLB flush, all the fix is belonging on vm_write_{begin,end} 
calls.

I did some test on x86_64 and PowerPC but that needs to be double check 
on arm64.

Vinayak, Zhong, could you please give it a try ?

Thanks,
Laurent.


--------------A64C24F948C10252E9481302
Content-Type: text/plain; charset=UTF-8; x-mac-type="0"; x-mac-creator="0";
 name="0001-mm-protect-against-PTE-changes-done-by-dup_mmap.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename*0="0001-mm-protect-against-PTE-changes-done-by-dup_mmap.patch"

RnJvbSAzYmU5NzdmZWJiOWZmOTNkNTE2YTJkMjIyY2NhNGI1YTUyNDcyYTlmIE1vbiBTZXAg
MTcgMDA6MDA6MDAgMjAwMQpGcm9tOiBMYXVyZW50IER1Zm91ciA8bGR1Zm91ckBsaW51eC5p
Ym0uY29tPgpEYXRlOiBGcmksIDE4IEphbiAyMDE5IDE2OjE5OjA4ICswMTAwClN1YmplY3Q6
IFtQQVRDSF0gbW06IHByb3RlY3QgYWdhaW5zdCBQVEUgY2hhbmdlcyBkb25lIGJ5IGR1cF9t
bWFwKCkKClZpbmF5YWsgTWVub24gYW5kIEdhbmVzaCBNYWhlbmRyYW4gcmVwb3J0ZWQgdGhh
dCB0aGUgZm9sbG93aW5nIHNjZW5hcmlvIG1heQpsZWFkIHRvIHRocmVhZCBiZWluZyBibG9j
a2VkIGR1ZSB0byBkYXRhIGNvcnJ1cHRpb246CgogICAgQ1BVIDEgICAgICAgICAgICAgICAg
ICAgQ1BVIDIgICAgICAgICAgICAgICAgICAgIENQVSAzCiAgICBQcm9jZXNzIDEsICAgICAg
ICAgICAgICBQcm9jZXNzIDEsICAgICAgICAgICAgICAgUHJvY2VzcyAxLAogICAgVGhyZWFk
IEEgICAgICAgICAgICAgICAgVGhyZWFkIEIgICAgICAgICAgICAgICAgIFRocmVhZCBDCgog
ICAgd2hpbGUgKDEpIHsgICAgICAgICAgICAgd2hpbGUgKDEpIHsgICAgICAgICAgICAgIHdo
aWxlKDEpIHsKICAgIHB0aHJlYWRfbXV0ZXhfbG9jayhsKSAgIHB0aHJlYWRfbXV0ZXhfbG9j
ayhsKSAgICBmb3JrCiAgICBwdGhyZWFkX211dGV4X3VubG9jayhsKSBwdGhyZWFkX211dGV4
X3VubG9jayhsKSAgfQogICAgfSAgICAgICAgICAgICAgICAgICAgICAgfQoKSW4gdGhlIGRl
dGFpbHMgdGhpcyBoYXBwZW5zIGJlY2F1c2UgOgoKICAgIENQVSAxICAgICAgICAgICAgICAg
IENQVSAyICAgICAgICAgICAgICAgICAgICAgICBDUFUgMwogICAgZm9yaygpCiAgICBjb3B5
X3B0ZV9yYW5nZSgpCiAgICAgIHNldCBQVEUgcmRvbmx5CiAgICBnb3QgdG8gbmV4dCBWTUEu
Li4KICAgICAuICAgICAgICAgICAgICAgICAgIFBURSBpcyBzZWVuIHJkb25seSAgICAgICAg
ICBQVEUgc3RpbGwgd3JpdGFibGUKICAgICAuICAgICAgICAgICAgICAgICAgIHRocmVhZCBp
cyB3cml0aW5nIHRvIHBhZ2UKICAgICAuICAgICAgICAgICAgICAgICAgIC0+IHBhZ2UgZmF1
bHQKICAgICAuICAgICAgICAgICAgICAgICAgICAgY29weSB0aGUgcGFnZSAgICAgICAgICAg
ICBUaHJlYWQgd3JpdGVzIHRvIHBhZ2UKICAgICAuICAgICAgICAgICAgICAgICAgICAgIC4g
ICAgICAgICAgICAgICAgICAgICAgICAtPiBubyBwYWdlIGZhdWx0CiAgICAgLiAgICAgICAg
ICAgICAgICAgICAgIHVwZGF0ZSB0aGUgUFRFCiAgICAgLiAgICAgICAgICAgICAgICAgICAg
IGZsdXNoIFRMQiBmb3IgdGhhdCBQVEUKICAgZmx1c2ggVExCICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgIFBURSBhcmUgbm93IHJkb25seQoKU28gdGhlIHdyaXRl
IGRvbmUgYnkgdGhlIENQVSAzIGlzIGludGVyZmVyaW5nIHdpdGggdGhlIHBhZ2UgY29weSBv
cGVyYXRpb24KZG9uZSBieSBDUFUgMiwgbGVhZGluZyB0byB0aGUgZGF0YSBjb3JydXB0aW9u
LgoKVG8gYXZvaWQgdGhpcyB3ZSBtYXJrIGFsbCB0aGUgVk1BIGludm9sdmVkIGluIHRoZSBD
T1cgbWVjaGFuaXNtIGFzIGNoYW5naW5nCmJ5IGNhbGxpbmcgdm1fd3JpdGVfYmVnaW4oKS4g
VGhpcyBlbnN1cmVzIHRoYXQgdGhlIHNwZWN1bGF0aXZlIHBhZ2UgZmF1bHQKaGFuZGxlciB3
aWxsIG5vdCB0cnkgdG8gaGFuZGxlIGEgZmF1bHQgb24gdGhlc2UgcGFnZXMuClRoZSBtYXJr
ZXIgaXMgc2V0IHVudGlsIHRoZSBUTEIgaXMgZmx1c2hlZCwgZW5zdXJpbmcgdGhhdCBhbGwg
dGhlIENQVXMgd2lsbApub3cgc2VlIHRoZSBQVEUgYXMgbm90IHdyaXRhYmxlLgpPbmNlIHRo
ZSBUTEIgaXMgZmx1c2gsIHRoZSBtYXJrZXIgaXMgcmVtb3ZlZCBieSBjYWxsaW5nIHZtX3dy
aXRlX2VuZCgpLgoKVGhlIHZhcmlhYmxlIGxhc3QgaXMgdXNlZCB0byBrZWVwIHRyYWNrZWQg
b2YgdGhlIGxhdGVzdCBWTUEgbWFya2VkIHRvCmhhbmRsZSB0aGUgZXJyb3IgcGF0aCB3aGVy
ZSBwYXJ0IG9mIHRoZSBWTUEgbWF5IGhhdmUgYmVlbiBtYXJrZWQuCgpSZXBvcnRlZC1ieTog
R2FuZXNoIE1haGVuZHJhbiA8b3BlbnNvdXJjZS5nYW5lc2hAZ21haWwuY29tPgpSZXBvcnRl
ZC1ieTogVmluYXlhayBNZW5vbiA8dmlubWVub25AY29kZWF1cm9yYS5vcmc+ClNpZ25lZC1v
ZmYtYnk6IExhdXJlbnQgRHVmb3VyIDxsZHVmb3VyQGxpbnV4LmlibS5jb20+Ci0tLQoga2Vy
bmVsL2ZvcmsuYyB8IDMwICsrKysrKysrKysrKysrKysrKysrKysrKysrKystLQogMSBmaWxl
IGNoYW5nZWQsIDI4IGluc2VydGlvbnMoKyksIDIgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0
IGEva2VybmVsL2ZvcmsuYyBiL2tlcm5lbC9mb3JrLmMKaW5kZXggZjEyNThjMmFkZTA5Li4z
OTg1NGI5N2QwNmEgMTAwNjQ0Ci0tLSBhL2tlcm5lbC9mb3JrLmMKKysrIGIva2VybmVsL2Zv
cmsuYwpAQCAtMzk1LDcgKzM5NSw3IEBAIEVYUE9SVF9TWU1CT0woZnJlZV90YXNrKTsKIHN0
YXRpYyBfX2xhdGVudF9lbnRyb3B5IGludCBkdXBfbW1hcChzdHJ1Y3QgbW1fc3RydWN0ICpt
bSwKIAkJCQkJc3RydWN0IG1tX3N0cnVjdCAqb2xkbW0pCiB7Ci0Jc3RydWN0IHZtX2FyZWFf
c3RydWN0ICptcG50LCAqdG1wLCAqcHJldiwgKipwcHJldjsKKwlzdHJ1Y3Qgdm1fYXJlYV9z
dHJ1Y3QgKm1wbnQsICp0bXAsICpwcmV2LCAqKnBwcmV2LCAqbGFzdCA9IE5VTEw7CiAJc3Ry
dWN0IHJiX25vZGUgKipyYl9saW5rLCAqcmJfcGFyZW50OwogCWludCByZXR2YWw7CiAJdW5z
aWduZWQgbG9uZyBjaGFyZ2U7CkBAIC01MTUsOCArNTE1LDE4IEBAIHN0YXRpYyBfX2xhdGVu
dF9lbnRyb3B5IGludCBkdXBfbW1hcChzdHJ1Y3QgbW1fc3RydWN0ICptbSwKIAkJcmJfcGFy
ZW50ID0gJnRtcC0+dm1fcmI7CiAKIAkJbW0tPm1hcF9jb3VudCsrOwotCQlpZiAoISh0bXAt
PnZtX2ZsYWdzICYgVk1fV0lQRU9ORk9SSykpCisJCWlmICghKHRtcC0+dm1fZmxhZ3MgJiBW
TV9XSVBFT05GT1JLKSkgeworCQkJaWYgKElTX0VOQUJMRUQoQ09ORklHX1NQRUNVTEFUSVZF
X1BBR0VfRkFVTFQpKSB7CisJCQkJLyoKKwkJCQkgKiBNYXJrIHRoaXMgVk1BIGFzIGNoYW5n
aW5nIHRvIHByZXZlbnQgdGhlCisJCQkJICogc3BlY3VsYXRpdmUgcGFnZSBmYXVsdCBoYW5s
ZGVyIHRvIHByb2Nlc3MKKwkJCQkgKiBpdCB1bnRpbCB0aGUgVExCIGFyZSBmbHVzaGVkIGJl
bG93LgorCQkJCSAqLworCQkJCWxhc3QgPSBtcG50OworCQkJCXZtX3dyaXRlX2JlZ2luKG1w
bnQpOworCQkJfQogCQkJcmV0dmFsID0gY29weV9wYWdlX3JhbmdlKG1tLCBvbGRtbSwgbXBu
dCk7CisJCX0KIAogCQlpZiAodG1wLT52bV9vcHMgJiYgdG1wLT52bV9vcHMtPm9wZW4pCiAJ
CQl0bXAtPnZtX29wcy0+b3Blbih0bXApOwpAQCAtNTMwLDYgKzU0MCwyMiBAQCBzdGF0aWMg
X19sYXRlbnRfZW50cm9weSBpbnQgZHVwX21tYXAoc3RydWN0IG1tX3N0cnVjdCAqbW0sCiBv
dXQ6CiAJdXBfd3JpdGUoJm1tLT5tbWFwX3NlbSk7CiAJZmx1c2hfdGxiX21tKG9sZG1tKTsK
KworCWlmIChJU19FTkFCTEVEKENPTkZJR19TUEVDVUxBVElWRV9QQUdFX0ZBVUxUKSkgewor
CQkvKgorCQkgKiBTaW5jZSB0aGUgVExCIGhhcyBiZWVuIGZsdXNoLCB3ZSBjYW4gc2FmZWx5
IHVubWFyayB0aGUKKwkJICogY29waWVkIFZNQXMgYW5kIGFsbG93cyB0aGUgc3BlY3VsYXRp
dmUgcGFnZSBmYXVsdCBoYW5kbGVyIHRvCisJCSAqIHByb2Nlc3MgdGhlbSBhZ2Fpbi4KKwkJ
ICogV2FsayBiYWNrIHRoZSBWTUEgbGlzdCBmcm9tIHRoZSBsYXN0IG1hcmtlZCBWTUEuCisJ
CSAqLworCQlmb3IgKDsgbGFzdDsgbGFzdCA9IGxhc3QtPnZtX3ByZXYpIHsKKwkJCWlmIChs
YXN0LT52bV9mbGFncyAmIFZNX0RPTlRDT1BZKQorCQkJCWNvbnRpbnVlOworCQkJaWYgKCEo
bGFzdC0+dm1fZmxhZ3MgJiBWTV9XSVBFT05GT1JLKSkKKwkJCQl2bV93cml0ZV9lbmQobGFz
dCk7CisJCX0KKwl9CisKIAl1cF93cml0ZSgmb2xkbW0tPm1tYXBfc2VtKTsKIAlkdXBfdXNl
cmZhdWx0ZmRfY29tcGxldGUoJnVmKTsKIGZhaWxfdXByb2JlX2VuZDoKLS0gCjIuMjAuMQoK

--------------A64C24F948C10252E9481302--
