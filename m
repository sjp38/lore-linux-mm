Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 910556B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 22:54:01 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id v13so1397518vbk.14
        for <linux-mm@kvack.org>; Tue, 06 Nov 2012 19:54:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANN689F6=mkJmgLFbALRPeYKG4RwTef+_r2TsHOLuobAxXbtPg@mail.gmail.com>
References: <508086DA.3010600@oracle.com>
	<5089A05E.7040000@gmail.com>
	<CA+1xoqf2v_jEapwU68BzXyi4abSRmi_=AiaJVHM3dBbHtsBnqQ@mail.gmail.com>
	<CAA_GA1d-rw_vkDF98fcf9E0=h86dsp+83-0_RE5b482juxaGVw@mail.gmail.com>
	<CANN689HXoCMTP4ZRMUNOGAdOBmizKyo6jMqbqAFx8wwPXp+AzQ@mail.gmail.com>
	<CAA_GA1eYHi4zWZwKp5KGi4gP7V8bfnSF=aLKMiN-Wi5JyLaCdw@mail.gmail.com>
	<CANN689HfmX8uBa17t38PYv2Ap5d3LPjShq81tbcgET5ZqzjzeQ@mail.gmail.com>
	<CANN689HM=h2k33sJcoDYys9LHVadv+NaGz00kG7O-OEH=qadvA@mail.gmail.com>
	<CANN689F6=mkJmgLFbALRPeYKG4RwTef+_r2TsHOLuobAxXbtPg@mail.gmail.com>
Date: Tue, 6 Nov 2012 19:54:00 -0800
Message-ID: <CANN689F8ScQdtNFgtREQcQLJEKYDcUGngNFFF6to5eakCz9FnQ@mail.gmail.com>
Subject: Re: mm: NULL ptr deref in anon_vma_interval_tree_verify
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, hughd@google.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Tue, Nov 6, 2012 at 12:24 AM, Michel Lespinasse <walken@google.com> wrote:
> On Mon, Nov 5, 2012 at 5:41 AM, Michel Lespinasse <walken@google.com> wrote:
>> On Sun, Nov 4, 2012 at 8:44 PM, Michel Lespinasse <walken@google.com> wrote:
>>> On Sun, Nov 4, 2012 at 8:14 PM, Bob Liu <lliubbo@gmail.com> wrote:
>>>> Hmm, I attached a simple fix patch.
>>>
>>> Reviewed-by: Michel Lespinasse <walken@google.com>
>>> (also ran some tests with it, but I could never reproduce the original
>>> issue anyway).
>>
>> Wait a minute, this is actually wrong. You need to call
>> vma_lock_anon_vma() / vma_unlock_anon_vma() to avoid the issue with
>> vma->anon_vma == NULL.
>>
>> I'll fix it and integrate it into my next patch series, which I intend
>> to send later today. (I am adding new code into validate_mm(), so that
>> it's easier to have it in the same patch series to avoid merge
>> conflicts)
>
> Hmmm, now I'm getting confused about anon_vma locking again :/
>
> As Hugh privately remarked to me, the same_vma linked list is supposed
> to be protected by exclusive mmap_sem ownership, not by anon_vma lock.
> So now looking at it a bit more, I'm not sure what race we're
> preventing by taking the anon_vma lock in validate_mm() ???

Looking at it a bit more:

the same_vma linked list is *generally* protected by *exclusive*
mmap_sem ownership. However, in expand_stack() we only have *shared*
mmap_sem ownership, so that two concurrent expand_stack() calls
(possibly on different vmas that have a different anon_vma lock) could
race with each other. For this reason we do need the validate_mm()
taking each vma's anon_vma lock (if any) before calling
anon_vma_interval_tree_verify().

While this justifies Bob's patch, this does not explain Sasha's
reports - in both of them the backtrace did not involve
expand_stack(), and there should be exclusive mmap_sem ownership, so
I'm still unclear as to what could be causing Sasha's issue.

Sasha, how reproduceable is this ?

Also, would the following change print something when the issue triggers ?

diff --git a/mm/mmap.c b/mm/mmap.c
index 619b280505fe..4c09e7ebcfa7 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -404,8 +404,13 @@ void validate_mm(struct mm_struct *mm)
        while (vma) {
                struct anon_vma_chain *avc;
                vma_lock_anon_vma(vma);
-               list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
+               list_for_each_entry(avc, &vma->anon_vma_chain, same_vma) {
+                       if (avc->vma != vma) {
+                               printk("avc->vma %p vma %p\n", avc->vma, vma);
+                               bug = 1;
+                       }
                        anon_vma_interval_tree_verify(avc);
+               }
                vma_unlock_anon_vma(vma);
                highest_address = vma->vm_end;
                vma = vma->vm_next;

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
