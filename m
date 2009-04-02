Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D3A2A6B003D
	for <linux-mm@kvack.org>; Thu,  2 Apr 2009 05:55:31 -0400 (EDT)
Received: by ewy8 with SMTP id 8so508351ewy.38
        for <linux-mm@kvack.org>; Thu, 02 Apr 2009 02:56:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1236851912.5090.93.camel@laptop>
References: <8c5a844a0903110255q45b7cdf4u1453ce40d495ee2c@mail.gmail.com>
	 <1236851912.5090.93.camel@laptop>
Date: Thu, 2 Apr 2009 12:56:22 +0300
Message-ID: <8c5a844a0904020256r3e073d01o1991e5111127ce42@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: use list.h for vma list
From: Daniel Lowengrub <lowdanie@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

I've been thinking for a while about the best way to implement Nick's
suggestions.  Specifically, how to implement vma_next without all the
extra conditions.  The main problem is that for vma_next to return a
vma and not a list_head it has to be know if vma->vm_list.next is
inside a vma or a mm so that it can call list_entry on it.

In the current code, something like next=3Dvma->next runs the risk of
having next=3DNULL so the next pointer is usually used in a if statement
like:
vm_area_struct *next=3Dvma->next;
if(next&&<check stuff with next>){<do stuff to next>}

What I want to do is to make vma_next return a list_head - without
calling list_entry, and a seperate function vma_entry return the
entry.  This way, vma_entry would be a simple wrapper for
vma->vm_list.next.  Then the above code snippet would read:
vm_area_struct *next;
list_head next_list =3Dvma_next(vma);
if(in_list(mm, next_list) && next=3Dvma_entry(next_list) && <check stuff
with next>)
{<do stuff to next>}

where in_list checks if next_list=3D=3Dmm->mm_vmas.
Or there could be a function called check_next which would do the
first two checks together so that we'd be able to write:

vm_area_struct *next;
if(check_next(vma, next) && <check stuff with next>){<do stuff to next>}

This does away with the redundant conditions that bothered Nick - the
check for the end of the list in vma_entry which returns NULL, and
then the check for next=3D=3DNULL in the if statements.

This would lead to further optimizations based on the fact that we
could now pass around list_heads instead of vma's and only call
vma_entry after verifying that the list_head is really in the list and
not the mm_vmas list_head.  This verification would be done in the
places that the current code checks for vma=3D=3DNULL - as in the example
above.

What do you think?
Daniel


On Thu, Mar 12, 2009 at 12:58 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> w=
rote:
>
> On Wed, 2009-03-11 at 11:55 +0200, Daniel Lowengrub wrote:
> > Use the linked list defined list.h for the list of vmas that's stored
> > in the mm_struct structure. =A0Wrapper functions "vma_next" and
> > "vma_prev" are also implemented. =A0Functions that operate on more than
> > one vma are now given a list of vmas as input.
> >
> > Signed-off-by: Daniel Lowengrub
>
> While this is the approach I've taken for a patch I'm working on, a
> better solution has come up if you keep the RB tree (I don't).
>
> It is, however, even more invasive than the this one ;-)
>
> Wolfram has been working on implementing a threaded RB-tree. This means
> rb_prev() and rb_next() will be O(1) operations, so you could simply use
> those to iterate the vmas.
>
> The only draw-back is that each and every RB-tree user in the kernel
> needs to be adapted because its not quite possible to maintain the
> current API.
>
> I was planning to help Wolfram do that, but I'm utterly swamped atm. :-(
>
> What needs to be done is introduce rb_left(), rb_right() and rb_node()
> helpers that for now look like:
>
> static inline struct rb_node *rb_left(struct rb_node *n)
> {
> =A0 =A0 =A0 =A0return n->rb_left;
> }
>
> static inline struct rb_node *rb_right(struct rb_node *n)
> {
> =A0 =A0 =A0 =A0return n->rb_right;
> }
>
> static inline struct rb_node *rb_node(struct rb_node *n)
> {
> =A0 =A0 =A0 =A0return n;
> }
>
> We need these because the left and right child pointers will be
> over-loaded with threading information.
>
> After that we can flip the implementation of the RB-tree.
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
