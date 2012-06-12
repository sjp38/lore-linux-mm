Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 63A336B0070
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 12:47:08 -0400 (EDT)
Received: by ggm4 with SMTP id 4so4656300ggm.14
        for <linux-mm@kvack.org>; Tue, 12 Jun 2012 09:47:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1206110944120.31180@router.home>
References: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com>
 <1339406250-10169-3-git-send-email-kosaki.motohiro@gmail.com> <alpine.DEB.2.00.1206110944120.31180@router.home>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 12 Jun 2012 12:46:44 -0400
Message-ID: <CAHGf_=rz7RVLoYB75pHOH5j-ka3Lf_oHk7ffT+AvOTLfYaWzDw@mail.gmail.com>
Subject: Re: [PATCH 2/6] mempolicy: remove all mempolicy sharing
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, stable@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jun 11, 2012 at 11:02 AM, Christoph Lameter <cl@linux.com> wrote:
> Some more attempts to cleanup changelogs:
>
>> The problem was created by a reference count imbalance. Example, In foll=
owing case,
>> mbind(addr, len) try to replace mempolicies of vma1 and vma2 and then th=
ey will
>> be share the same mempolicy, and the new mempolicy has MPOL_F_SHARED fla=
g.
>
> The bug that we saw <where ? details?> was created by a refcount
> imbalance. If mbind() replaces the memory policies of vma1 and vma and
> they share the same shared mempolicy (MPOL_F_SHARED set) then an imbalanc=
e
> may occur.
>
>> =A0 +-------------------+-------------------+
>> =A0 | =A0 =A0 vma1 =A0 =A0 =A0 =A0 =A0| =A0 =A0 vma2(shmem) =A0 |
>> =A0 +-------------------+-------------------+
>> =A0 | =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 |
>> =A0addr =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
addr+len
>>
>> Look at alloc_pages_vma(), it uses get_vma_policy() and mpol_cond_put() =
pair
>> for maintaining mempolicy refcount. The current rule is, get_vma_policy(=
) does
>> NOT increase a refcount if the policy is not attached shmem vma and mpol=
_cond_put()
>> DOES decrease a refcount if mpol has MPOL_F_SHARED.
>
> alloc_pages_vma() uses the two function get_vma_policy() and
> mpol_cond_put() to maintain the refcount on the memory policies. However,
> the current rule is that get_vma_policy() does *not* increase the refcoun=
t
> if the policy is not attached to a shm vma. mpol_cond_put *does* decrease
> the refcount if the memory policy has MPOL_F_SHARED set.
>
>> In above case, vma1 is not shmem vma and vma->policy has MPOL_F_SHARED! =
then,
>> get_vma_policy() doesn't increase a refcount and mpol_cond_put() decreas=
e a
>> refcount whenever alloc_page_vma() is called.
>>
>> The bug was introduced by commit 52cd3b0740 (mempolicy: rework mempolicy=
 Reference
>> Counting) at 4 years ago.
>>
>> More unfortunately mempolicy has one another serious broken. Currently,
>> mempolicy rebind logic (it is called from cpuset rebinding) ignore a ref=
count
>> of mempolicy and override it forcibly. Thus, any mempolicy sharing may
>> cause mempolicy corruption. The bug was introduced by commit 68860ec10b
>> (cpusets: automatic numa mempolicy rebinding) at 7 years ago.
>
> Memory policies have another issue. Currently the mempolicy rebind logic
> used for cpuset rebinding ignores the refcount of memory policies.
> Therefore, any memory policy sharing can cause refcount mismatches. The
> bug was ...
>
>> To disable policy sharing solves user visible breakage and this patch do=
es it.
>> Maybe, we need to rewrite MPOL_F_SHARED and mempolicy rebinding code and=
 aim
>> to proper cow logic eventually, but I think this is good first step.
>
> Disabling policy sharing solves the breakage and that is how this patch
> fixes the issue for now. Rewriting the shared policy handling with proper
> COW logic support will be necessary to cleanly address the
> problem and allow proper sharing of memory policies.

Thanks, Christoph.
I'll rewrite the description as your suggestion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
