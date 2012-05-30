Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 2B2836B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 15:40:06 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so153654vcb.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 12:40:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1205301414020.31768@router.home>
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com>
 <1338368529-21784-2-git-send-email-kosaki.motohiro@gmail.com> <alpine.DEB.2.00.1205301414020.31768@router.home>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 30 May 2012 15:39:44 -0400
Message-ID: <CAHGf_=oLsK2bk_ym6EZfFD=uRpr33CL+1=nWmf4hrnCxUOFisQ@mail.gmail.com>
Subject: Re: [PATCH 1/6] Revert "mm: mempolicy: Let vma_merge and vma_split
 handle vma->vm_policy linkages"
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, stable@vger.kernel.org, hughd@google.com, Andrew Morton <akpm@linux-foundation.org>

On Wed, May 30, 2012 at 3:17 PM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 30 May 2012, kosaki.motohiro@gmail.com wrote:
>
>> From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
>>
>> commit 05f144a0d5 removed vma->vm_policy updates code and it is a purpos=
e of
>> mbind_range(). Now, mbind_range() is virtually no-op. no-op function don=
't
>> makes any bugs, I agree. but maybe it is not right fix.
>
> I dont really understand the changelog. But to restore the policy_vma() i=
s
> the right thing to do since there are potential multiple use cases where
> we want to apply a policy to a vma.
>
> Proposed new changelog:
>
> Commit 05f144a0d5 folded policy_vma() into mbind_range(). There are
> other use cases of policy_vma(*) though and so revert a piece of
> that commit in order to have a policy_vma() function again.
>
>> @@ -655,23 +676,9 @@ static int mbind_range(struct mm_struct *mm, unsign=
ed long start,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (err)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> -
>> - =A0 =A0 =A0 =A0 =A0 =A0 /*
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0* Apply policy to a single VMA. The referen=
ce counting of
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0* policy for vma_policy linkages has alread=
y been handled by
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0* vma_merge and split_vma as necessary. If =
this is a shared
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0* policy then ->set_policy will increment t=
he reference count
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0* for an sp node.
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>
> You are dropping the nice comments by Mel that explain the refcounting.

Because this is not strictly correct. 1) vma_merge() and split_vma() don't
care mempolicy refcount. They only dup and drop it. 2) This mpol_get() is
for vma attaching. This function don't need to care sp_node internal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
