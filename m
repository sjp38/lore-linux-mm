Message-ID: <49252A54.6010602@redhat.com>
Date: Thu, 20 Nov 2008 11:13:56 +0200
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux v2
References: <1226888432-3662-1-git-send-email-ieidus@redhat.com> <5e93dcec0811192344l3813867egcc6b5a3c666142b9@mail.gmail.com> <492527DF.1080602@redhat.com>
In-Reply-To: <492527DF.1080602@redhat.com>
Content-Type: multipart/mixed;
 boundary="------------090500050002060706000102"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ryota OZAKI <ozaki.ryota@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, dlaor@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, cl@linux-foundation.org, corbet@lwn.net
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090500050002060706000102
Content-Type: text/plain; charset=windows-1255; format=flowed
Content-Transfer-Encoding: 8bit

oeeae Izik Eidus:
> oeeae Ryota OZAKI:
>> Hi Izik,
>>
>> I've tried your patch set, but ksm doesn't work in my machine.
>>
>> I compiled linux patched with the four patches and configured with KSM
>> and KVM enabled. After boot with the linux, I run two VMs running linux
>> using QEMU with a patch in your mail and started KSM scanner with your
>> script, then the host linux caused panic with the following oops.
>>   
>
> Yes you are right, we are missing pte_unmap(pte); in get_pte()!
> that will effect just 32bits with highmem so this why you see it
> thanks for the reporting, i will fix it for v3
>
> below patch should fix it (i cant test it now, will test it for v3)
>
> can you report if it fix your problem? thanks
>
Thinking about what i just did, it is wrong,
this patch is the right one (still wasnt tested), but if you are going 
to apply something then use this one.

thanks

--------------090500050002060706000102
Content-Type: text/plain;
 name="fix_highmem_2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix_highmem_2"

diff --git a/mm/ksm.c b/mm/ksm.c
index 707be52..c842c29 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -569,14 +569,16 @@ out:
 static int is_present_pte(struct mm_struct *mm, unsigned long addr)
 {
 	pte_t *ptep;
+	int r;
 
 	ptep = get_pte(mm, addr);
 	if (!ptep)
 		return 0;
 
-	if (pte_present(*ptep))
-		return 1;
-	return 0;
+	r = pte_present(*ptep);
+	pte_unmap(ptep);
+
+	return r;
 }
 
 #define PAGEHASH_LEN 128
@@ -669,6 +671,7 @@ static int try_to_merge_one_page(struct mm_struct *mm,
 	if (!orig_ptep)
 		goto out_unlock;
 	orig_pte = *orig_ptep;
+	pte_unmap(orig_ptep);
 	if (!pte_present(orig_pte))
 		goto out_unlock;
 	if (page_to_pfn(oldpage) != pte_pfn(orig_pte))

--------------090500050002060706000102--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
