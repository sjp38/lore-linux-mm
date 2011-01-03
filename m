Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 84D966B00AD
	for <linux-mm@kvack.org>; Mon,  3 Jan 2011 09:09:54 -0500 (EST)
Received: by qwa26 with SMTP id 26so13518604qwa.14
        for <linux-mm@kvack.org>; Mon, 03 Jan 2011 06:09:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110103135815.GA6024@thunk.org>
References: <E1PZXeb-0004AV-2b@tytso-glaptop>
	<AANLkTi=9ZNk6w8PxvveWHy5+okfTyKUj3L2ywFOuFjoq@mail.gmail.com>
	<AANLkTinz52Ky5BhU-gHq8vx9=1uoN+iuDn1f0C8fnSjQ@mail.gmail.com>
	<20110103135815.GA6024@thunk.org>
Date: Mon, 3 Jan 2011 16:09:52 +0200
Message-ID: <AANLkTimksbK5oa5vMvbSUwtY2XmApNDi4wdCuvfy9vcq@mail.gmail.com>
Subject: Re: Should we be using unlikely() around tests of GFP_ZERO?
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ted Ts'o <tytso@mit.edu>, Pekka Enberg <penberg@kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, David Rientjes <rientjes@google.com>, npiggin@kernel.dk
List-ID: <linux-mm.kvack.org>

Hi Ted,

On Mon, Jan 03, 2011 at 09:40:57AM +0200, Pekka Enberg wrote:
>> I guess the rationale here is that if you're going to take the hit of
>> memset() you can take the hit of unlikely() as well. We're optimizing
>> for hot call-sites that allocate a small amount of memory and
>> initialize everything themselves. That said, I don't think the
>> unlikely() annotation matters much either way and am for removing it
>> unless people object to that.

On Mon, Jan 3, 2011 at 3:58 PM, Ted Ts'o <tytso@mit.edu> wrote:
> I suspect for many slab caches, all of the slab allocations for a
> given slab cache type will have the GFP_ZERO flag passed. =A0So maybe it
> would be more efficient to zap the entire page when it is pressed into
> service for a particular slab cache, so we can avoid needing to use
> memset on a per-object basis?

We'd then need to do memset() in kmem_cache_free() because callers are
not required to clean up after them. In general, we don't want to do
that because object cachelines are less likely to be touched after
free than they are after allocation (you usually use the memory
immediately after you allocate).

                      Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
