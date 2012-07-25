Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 29E636B004D
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 13:55:14 -0400 (EDT)
Message-ID: <501032A3.3010705@redhat.com>
Date: Wed, 25 Jul 2012 13:53:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/6] rbtree: faster augmented erase
References: <1342787467-5493-1-git-send-email-walken@google.com> <1342787467-5493-6-git-send-email-walken@google.com> <20120724015410.GA9690@google.com>
In-Reply-To: <20120724015410.GA9690@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/23/2012 09:54 PM, Michel Lespinasse wrote:
> Add an augmented tree rotation callback to __rb_erase_color(), so that
> augmented tree information can be maintained while rebalancing.
>
> Also introduce rb_erase_augmented(), which is a version of rb_erase()
> with augmented tree callbacks. We need three callbacks here: one to
> copy the subtree's augmented value after stitching in a new node as
> the subtree root (rb_erase_augmented cases 2 and 3), one to propagate
> the augmented values up after removing a node, and one to pass up to
> __rb_erase_color() to handle rebalancing.
>
> Things are set up so that rb_erase() uses dummy do-nothing callbacks,
> which get inlined and eliminated by the compiler, and also inlines the
> __rb_erase_color() call so as to generate similar code than before
> (once again, the compiler somehow generates smaller code than before
> with all that inlining, but the speed seems to be on par). For the
> augmented version rb_erase_augmented(), however, we use partial
> inlining: we want rb_erase_augmented() and its augmented copy and
> propagation callbacks to get inlined together, but we still call into
> a generic __rb_erase_color() (passing a non-inlined callback function)
> for the rebalancing work. This is intended to strike a reasonable
> compromise between speed and compiled code size.

I guess moving the inlined function to the include file
takes care of my concerns for patch 4/6...

> Signed-off-by: Michel Lespinasse <walken@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
