Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EEBEC6B004D
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 02:56:35 -0400 (EDT)
Received: by fxm2 with SMTP id 2so3393624fxm.38
        for <linux-mm@kvack.org>; Mon, 29 Jun 2009 23:58:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090630060031.GL7070@linux.vnet.ibm.com>
References: <20090625193137.GA16861@linux.vnet.ibm.com>
	 <alpine.DEB.1.10.0906291827050.21956@gentwo.org>
	 <1246315553.21295.100.camel@calx>
	 <alpine.DEB.1.10.0906291910130.32637@gentwo.org>
	 <1246320394.21295.105.camel@calx>
	 <20090630060031.GL7070@linux.vnet.ibm.com>
Date: Tue, 30 Jun 2009 09:58:22 +0300
Message-ID: <84144f020906292358j6517b599n471eed4e88781a78@mail.gmail.com>
Subject: Re: [PATCH RFC] fix RCU-callback-after-kmem_cache_destroy problem in
	sl[aou]b
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: paulmck@linux.vnet.ibm.com
Cc: Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jdb@comx.dk
List-ID: <linux-mm.kvack.org>

On Tue, Jun 30, 2009 at 9:00 AM, Paul E.
McKenney<paulmck@linux.vnet.ibm.com> wrote:
> On Mon, Jun 29, 2009 at 07:06:34PM -0500, Matt Mackall wrote:
>> On Mon, 2009-06-29 at 19:19 -0400, Christoph Lameter wrote:
>> > On Mon, 29 Jun 2009, Matt Mackall wrote:
>> >
>> > > This is a reasonable point, and in keeping with the design principle
>> > > 'callers should handle their own special cases'. However, I think it
>> > > would be more than a little surprising for kmem_cache_free() to do the
>> > > right thing, but not kmem_cache_destroy().
>> >
>> > kmem_cache_free() must be used carefully when using SLAB_DESTROY_BY_RCU.
>> > The freed object can be accessed after free until the rcu interval
>> > expires (well sortof, it may even be reallocated within the interval).
>> >
>> > There are special RCU considerations coming already with the use of
>> > kmem_cache_free().
>> >
>> > Adding RCU operations to the kmem_cache_destroy() logic may result in
>> > unnecessary RCU actions for slabs where the coder is ensuring that the
>> > RCU interval has passed by other means.
>>
>> Do we care? Cache destruction shouldn't be in anyone's fast path.
>> Correctness is more important and users are more liable to be correct
>> with this patch.
>
> I am with Matt on this one -- if we are going to hand the users of
> SLAB_DESTROY_BY_RCU a hand grenade, let's at least leave the pin in.

I don't even claim to understand all the RCU details here but I don't
see why we should care about _kmem_cache_destroy()_ performance at
this level. Christoph, hmmm?

                              Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
