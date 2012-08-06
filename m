Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 0D39D6B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 11:39:04 -0400 (EDT)
Message-ID: <1344267537.27828.93.camel@twins>
Subject: Re: [PATCH v2 8/9] rbtree: faster augmented rbtree manipulation
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 06 Aug 2012 17:38:57 +0200
In-Reply-To: <1344262669.27828.55.camel@twins>
References: <1343946858-8170-1-git-send-email-walken@google.com>
	 <1343946858-8170-9-git-send-email-walken@google.com>
	 <1344262669.27828.55.camel@twins>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On Mon, 2012-08-06 at 16:17 +0200, Peter Zijlstra wrote:

> Why would every user need to replicate the propagate and rotate
> boilerplate?

So I don't have a tree near that any of this applies to (hence no actual
patch), but why can't we have something like:

struct rb_augment_callback {
	const bool (*update)(struct rb_node *node);
	const int offset;
	const int size;
};

#define RB_AUGMENT_CALLBACK(_update, _type, _rb_member, _aug_member)	\
(struct rb_augment_callback){						\
	.update =3D _update,						\
	.offset =3D offsetof(_type, _aug_member) - 			\
		  offsetof(_type, _rb_member),				\
	.size   =3D sizeof(((_type *)NULL)->_aug_member),			\
}

static __always_inline void=20
augment_copy(struct rb_node *dst, struct rb_node *src,
	     const rb_augment_callback *ac)
{
	memcpy((void *)dst + ac->offset,
	       (void *)src + ac->offset,
	       ac->size);
}=20

static __always_inline void=20
augment_propagate(struct rb_node *rb, struct rb_node *stop,
		  const struct rb_augment_callback *ac)
{
	while (rb !=3D stop) {
		if (!ac->update(rb))
			break;
		rb =3D rb_parent(rb);
	}
}

static __always_inline void
augment_rotate(struct rb_node *old, struct rb_node *new.
	       const struct rb_augment_callback *ac)
{
	augment_copy(new, old, ac);
	(void)ac->update(old);
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
