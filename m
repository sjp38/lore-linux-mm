Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 801786B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 07:22:02 -0400 (EDT)
Received: by vws4 with SMTP id 4so6084425vws.14
        for <linux-mm@kvack.org>; Tue, 14 Jun 2011 04:22:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1106140341070.29206@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
	<alpine.LSU.2.00.1106140341070.29206@sister.anvils>
Date: Tue, 14 Jun 2011 14:22:00 +0300
Message-ID: <BANLkTinGHSpn2aF-HM-R-eu12ZqMTpHQdQ@mail.gmail.com>
Subject: Re: [PATCH 1/12] radix_tree: exceptional entries and indices
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Hugh!

On Tue, Jun 14, 2011 at 1:42 PM, Hugh Dickins <hughd@google.com> wrote:
> @@ -39,7 +39,15 @@
> =A0* when it is shrunk, before we rcu free the node. See shrink code for
> =A0* details.
> =A0*/
> -#define RADIX_TREE_INDIRECT_PTR =A0 =A0 =A0 =A01
> +#define RADIX_TREE_INDIRECT_PTR =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01
> +/*
> + * A common use of the radix tree is to store pointers to struct pages;
> + * but shmem/tmpfs needs also to store swap entries in the same tree:
> + * those are marked as exceptional entries to distinguish them.
> + * EXCEPTIONAL_ENTRY tests the bit, EXCEPTIONAL_SHIFT shifts content pas=
t it.
> + */
> +#define RADIX_TREE_EXCEPTIONAL_ENTRY =A0 2
> +#define RADIX_TREE_EXCEPTIONAL_SHIFT =A0 2
>
> =A0#define radix_tree_indirect_to_ptr(ptr) \
> =A0 =A0 =A0 =A0radix_tree_indirect_to_ptr((void __force *)(ptr))
> @@ -174,6 +182,28 @@ static inline int radix_tree_deref_retry
> =A0}
>
> =A0/**
> + * radix_tree_exceptional_entry =A0 =A0 =A0 =A0- radix_tree_deref_slot g=
ave exceptional entry?
> + * @arg: =A0 =A0 =A0 value returned by radix_tree_deref_slot
> + * Returns: =A0 =A00 if well-aligned pointer, non-0 if exceptional entry=
.
> + */
> +static inline int radix_tree_exceptional_entry(void *arg)
> +{
> + =A0 =A0 =A0 /* Not unlikely because radix_tree_exception often tested f=
irst */
> + =A0 =A0 =A0 return (unsigned long)arg & RADIX_TREE_EXCEPTIONAL_ENTRY;
> +}
> +
> +/**
> + * radix_tree_exception =A0 =A0 =A0 =A0- radix_tree_deref_slot returned =
either exception?
> + * @arg: =A0 =A0 =A0 value returned by radix_tree_deref_slot
> + * Returns: =A0 =A00 if well-aligned pointer, non-0 if either kind of ex=
ception.
> + */
> +static inline int radix_tree_exception(void *arg)
> +{
> + =A0 =A0 =A0 return unlikely((unsigned long)arg &
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (RADIX_TREE_INDIRECT_PTR | RADIX_TREE_EXCEP=
TIONAL_ENTRY));
> +}

Would something like radix_tree_augmented() be a better name for this
(with RADIX_TREE_AUGMENTED_MASK defined)? This one seems too easy to
confuse with radix_tree_exceptional_entry() to me which is not the
same thing, right?

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
