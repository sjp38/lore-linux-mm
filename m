Date: Wed, 22 Oct 2008 12:54:30 -0700 (PDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: SLUB defrag pull request?
In-Reply-To: <E1Ksjed-00023D-UB@pomaz-ex.szeredi.hu>
Message-ID: <Pine.LNX.4.64.0810221252570.3562@quilx.com>
References: <1223883004.31587.15.camel@penberg-laptop>
 <1223883164.31587.16.camel@penberg-laptop> <Pine.LNX.4.64.0810131227120.20511@blonde.site>
 <200810132354.30789.nickpiggin@yahoo.com.au> <E1KpNwq-0003OW-8f@pomaz-ex.szeredi.hu>
 <E1KpOOL-0003Vf-9y@pomaz-ex.szeredi.hu> <48F378C6.7030206@linux-foundation.org>
 <E1KpOjX-0003dt-AY@pomaz-ex.szeredi.hu> <48FC9CCC.3040006@linux-foundation.org>
 <E1Krz4o-0002Fi-Pu@pomaz-ex.szeredi.hu> <48FCCC72.5020202@linux-foundation.org>
 <E1KrzgK-0002QS-Os@pomaz-ex.szeredi.hu> <48FCD7CB.4060505@linux-foundation.org>
 <E1Ks0QX-0002aC-SQ@pomaz-ex.szeredi.hu> <48FCE1C4.20807@linux-foundation.org>
 <E1Ks1hu-0002nN-9f@pomaz-ex.szeredi.hu> <48FE6306.6020806@linux-foundation.org>
 <E1KsXrY-0000AU-C4@pomaz-ex.szeredi.hu> <Pine.LNX.4.64.0810220822500.30851@quilx.com>
 <E1Ksjed-00023D-UB@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: penberg@cs.helsinki.fi, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Oct 2008, Miklos Szeredi wrote:

> Why?  The kmem_cache_free() doesn't touch the contents of the object,
> does it?

Because filesystem code may be running on other processors which may be 
freeing the dentry.

>> Because the slab starts out with a series of objects left in a slab. It
>> needs to do build a list of objects etc in a way that is independent as
>> possible from the user of the slab page. It does that by locking the slab
>> page so that free operations stall until the reference has been
>> established. If it would not be shutting off frees then the objects could
>> vanish under us.
>
> It doesn't matter.  All we care about is that the dentry is on the
> lru: it's cached but unused.  Every other state (being created,
> active, being freed, freed) is uninteresting.

We cannot figure out that it is on the lru if we do not have a stable 
reference to the object.

> Sure, and all that is possible without doing this messy 2 phase thing.
> Unless I'm still missing something obvious...

Obviously one cannot free or handle an object that may be concurrently 
freed on another processor.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
