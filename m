Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D5F666B01FC
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 22:55:58 -0400 (EDT)
Received: by iwn40 with SMTP id 40so6093198iwn.1
        for <linux-mm@kvack.org>; Wed, 28 Apr 2010 19:55:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BD8EA85.2000209@redhat.com>
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
	 <20100428153525.GR510@random.random>
	 <20100428155558.GI15815@csn.ul.ie>
	 <20100428162305.GX510@random.random>
	 <20100428134719.32e8011b@annuminas.surriel.com>
	 <20100428142510.09984e15@annuminas.surriel.com>
	 <20100428161711.5a815fa8@annuminas.surriel.com>
	 <20100428165734.6541bab3@annuminas.surriel.com>
	 <y2s28c262361004281728we31e3b9fsd2427aacdc76a9e7@mail.gmail.com>
	 <4BD8EA85.2000209@redhat.com>
Date: Thu, 29 Apr 2010 11:55:57 +0900
Message-ID: <z2g28c262361004281955h29bc20edndb8da9c7cb5ff1db@mail.gmail.com>
Subject: Re: [RFC PATCH -v3] take all anon_vma locks in anon_vma_lock
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 29, 2010 at 11:10 AM, Rik van Riel <riel@redhat.com> wrote:
> On 04/28/2010 08:28 PM, Minchan Kim wrote:
>>
>> On Thu, Apr 29, 2010 at 5:57 AM, Rik van Riel<riel@redhat.com> =C2=A0wro=
te:
>>>
>>> Take all the locks for all the anon_vmas in anon_vma_lock, this properl=
y
>>> excludes migration and the transparent hugepage code from VMA changes
>>> done
>>> by mmap/munmap/mprotect/expand_stack/etc...
>>>
>>> Unfortunately, this requires adding a new lock (mm->anon_vma_chain_lock=
),
>>> otherwise we have an unavoidable lock ordering conflict. =C2=A0This cha=
nges
>>> the
>>> locking rules for the "same_vma" list to be either mm->mmap_sem for
>>> write,
>>> or mm->mmap_sem for read plus the new mm->anon_vma_chain lock. =C2=A0Th=
is
>>> limits
>>> the place where the new lock is taken to 2 locations - anon_vma_prepare
>>> and
>>> expand_downwards.
>>>
>>> Document the locking rules for the same_vma list in the anon_vma_chain
>>> and
>>> remove the anon_vma_lock call from expand_upwards, which does not need
>>> it.
>>>
>>> Signed-off-by: Rik van Riel<riel@redhat.com>
>>
>> This patch makes things simple. So I like this.
>> Actually, I wanted this all-at-once locks approach.
>> But I was worried about that how the patch affects AIM 7 workload
>> which is cause of anon_vma_chain about scalability by Rik.
>> But now Rik himself is sending the patch. So I assume the patch
>> couldn't decrease scalability of the workload heavily.
>
> The thing is, the number of anon_vmas attached to a VMA is
> small (depth of the tree, so for apache or aim the typical
> depth is 2). This N is between 1 and 3.
>
> The problem we had originally is the _width_ of the tree,
> where every sibling process was attached to the same anon_vma
> and the rmap code had to walk the page tables of all the
> processes, for every privately owned page in each child process.
> For large server workloads, this N is between a few hundred and
> a few thousand.
>
> What matters most at this point is correctness - we need to be
> able to exclude rmap walks when messing with a VMA in any way
> that breaks lookups, because rmap walks for page migration and
> hugepage conversion have to be 100% reliable.
>
> That is not a constraint I had in mind with the original
> anon_vma changes, so the code needs to be fixed up now...

Yes. I understand it.

When you tried anon_vma_chain patches as I pointed out, what I have a
concern is parent's vma not child's one.
The vma of parent still has N anon_vma.
AFAIR, you said it's trade-off and would be good than old at least.
I agreed.  But I just want to remind you because this makes worse.  :)
The corner case is that we have to hold locks of N.

Do I miss something?
Really, Can't we ignore that case latency although this happen infrequently=
?
I am not against this patch. I just want to listen your opinion.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
