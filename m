Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5BF2A6B009F
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 15:26:16 -0500 (EST)
Date: Mon, 16 Feb 2009 21:28:22 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 7/8] ecryptfs: use kzfree()
Message-ID: <20090216202822.GA2759@cmpxchg.org>
References: <20090216142926.440561506@cmpxchg.org> <20090216144726.088020837@cmpxchg.org> <20090216120204.44f78aa2.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090216120204.44f78aa2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tyler Hicks <tyhicks@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 16, 2009 at 12:02:04PM -0800, Andrew Morton wrote:
> On Mon, 16 Feb 2009 15:29:33 +0100 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > --- a/fs/ecryptfs/keystore.c
> > +++ b/fs/ecryptfs/keystore.c
> > @@ -740,8 +740,7 @@ ecryptfs_write_tag_70_packet(char *dest,
> >  out_release_free_unlock:
> >  	crypto_free_hash(s->hash_desc.tfm);
> >  out_free_unlock:
> > -	memset(s->block_aligned_filename, 0, s->block_aligned_filename_size);
> > -	kfree(s->block_aligned_filename);
> > +	kzfree(s->block_aligned_filename);
> >  out_unlock:
> >  	mutex_unlock(s->tfm_mutex);
> >  out:
> > --- a/fs/ecryptfs/messaging.c
> > +++ b/fs/ecryptfs/messaging.c
> > @@ -291,8 +291,7 @@ int ecryptfs_exorcise_daemon(struct ecry
> >  	if (daemon->user_ns)
> >  		put_user_ns(daemon->user_ns);
> >  	mutex_unlock(&daemon->mux);
> > -	memset(daemon, 0, sizeof(*daemon));
> > -	kfree(daemon);
> > +	kzfree(daemon);
> >  out:
> >  	return rc;
> >  }
> 
> Except for this one and the crypto one, which might have been done for
> security reasons.

Actually, only atm is not security related and should probably be
dropped.  I didn't convert w1 for the same reason.

> Even though both of them forgot to add a comment explaining this, which
> is bad, wrong, stupid and irritating.  Sigh.

Humm, I considered

	kfree(stuff->foo);
	kzfree(stuff->secret_password);
	kfree(stuff);

self-explaining.

Comments could still be added.  Even easier, as kzfree() is easier to
grep for then a memset() + kfree() sequence ;)

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
