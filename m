From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/1] mm/slub.c: add a naive detection of double free or
 corruption
Date: Mon, 17 Jul 2017 13:04:34 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1707171303230.12109@nuc-kabylake>
References: <1500309907-9357-1-git-send-email-alex.popov@linux.com> <20170717175459.GC14983@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <kernel-hardening-return-8985-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <20170717175459.GC14983@bombadil.infradead.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Alexander Popov <alex.popov@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, keescook@chromium.org
List-Id: linux-mm.kvack.org

On Mon, 17 Jul 2017, Matthew Wilcox wrote:

> On Mon, Jul 17, 2017 at 07:45:07PM +0300, Alexander Popov wrote:
> > Add an assertion similar to "fasttop" check in GNU C Library allocator:
> > an object added to a singly linked freelist should not point to itself.
> > That helps to detect some double free errors (e.g. CVE-2017-2636) without
> > slub_debug and KASAN. Testing with hackbench doesn't show any noticeable
> > performance penalty.
>
> >  {
> > +	BUG_ON(object == fp); /* naive detection of double free or corruption */
> >  	*(void **)(object + s->offset) = fp;
> >  }
>
> Is BUG() the best response to this situation?  If it's a corruption, then
> yes, but if we spot a double-free, then surely we should WARN() and return
> without doing anything?

The double free debug checking already does the same thing in a more
thourough way (this one only checks if the last free was the same
address). So its duplicating a check that already exists. However, this
one is always on.
