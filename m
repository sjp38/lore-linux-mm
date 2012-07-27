Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 36DD86B005A
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 16:03:03 -0400 (EDT)
Message-ID: <1343419375.32120.48.camel@twins>
Subject: Re: [PATCH 5/6] rbtree: faster augmented erase
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 27 Jul 2012 22:02:55 +0200
In-Reply-To: <1342787467-5493-6-git-send-email-walken@google.com>
References: <1342787467-5493-1-git-send-email-walken@google.com>
	 <1342787467-5493-6-git-send-email-walken@google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: riel@redhat.com, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2012-07-20 at 05:31 -0700, Michel Lespinasse wrote:
> +static inline void
> +rb_erase_augmented(struct rb_node *node, struct rb_root *root,
> +                  rb_augment_propagate *augment_propagate,
> +                  rb_augment_rotate *augment_rotate)=20

So why put all this in a static inline in a header? As it stands
rb_erase() isn't inlined and its rather big, why would you want to
inline it for augmented callers?=20

You could at least pull out the initial erase stuff into a separate
function, that way the rb_erase_augmented thing would shrink to
something like:

rb_erase_augmented(node, root)
{
	struct rb_node *parent, *child;
	bool black;

	__rb_erase(node, root, &parent, &child, &black);
	augmented_propagate(parent);
	if (black)
		__rb_erase_color(child, parent, root, augment_rotate);
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
