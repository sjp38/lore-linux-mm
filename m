Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5FBA76B00A6
	for <linux-mm@kvack.org>; Mon,  3 Jan 2011 02:41:03 -0500 (EST)
Received: by vws10 with SMTP id 10so5449105vws.14
        for <linux-mm@kvack.org>; Sun, 02 Jan 2011 23:41:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=9ZNk6w8PxvveWHy5+okfTyKUj3L2ywFOuFjoq@mail.gmail.com>
References: <E1PZXeb-0004AV-2b@tytso-glaptop>
	<AANLkTi=9ZNk6w8PxvveWHy5+okfTyKUj3L2ywFOuFjoq@mail.gmail.com>
Date: Mon, 3 Jan 2011 09:40:57 +0200
Message-ID: <AANLkTinz52Ky5BhU-gHq8vx9=1uoN+iuDn1f0C8fnSjQ@mail.gmail.com>
Subject: Re: Should we be using unlikely() around tests of GFP_ZERO?
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, David Rientjes <rientjes@google.com>, npiggin@kernel.dk
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Jan 3, 2011 at 8:48 AM, Theodore Ts'o <tytso@mit.edu> wrote:
>> Given the patches being busily submitted by trivial patch submitters to
>> make use kmem_cache_zalloc(), et. al, I believe we should remove the
>> unlikely() tests around the (gfp_flags & __GFP_ZERO) tests, such as:
>>
>> - =A0 =A0 =A0 if (unlikely((flags & __GFP_ZERO) && objp))
>> + =A0 =A0 =A0 if ((flags & __GFP_ZERO) && objp)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memset(objp, 0, obj_size(cachep));
>>
>> Agreed? =A0If so, I'll send a patch...

On Mon, Jan 3, 2011 at 5:46 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> I support it.

I guess the rationale here is that if you're going to take the hit of
memset() you can take the hit of unlikely() as well. We're optimizing
for hot call-sites that allocate a small amount of memory and
initialize everything themselves. That said, I don't think the
unlikely() annotation matters much either way and am for removing it
unless people object to that.

On Mon, Jan 3, 2011 at 5:46 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> Recently Steven tried to gather the information.
> http://thread.gmane.org/gmane.linux.kernel/1072767
> Maybe he might have a number for that.

That would be interesting, sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
