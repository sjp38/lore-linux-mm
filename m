Message-ID: <48FCD7CB.4060505@linux-foundation.org>
Date: Mon, 20 Oct 2008 14:11:07 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: SLUB defrag pull request?
References: <1223883004.31587.15.camel@penberg-laptop> <1223883164.31587.16.camel@penberg-laptop> <Pine.LNX.4.64.0810131227120.20511@blonde.site> <200810132354.30789.nickpiggin@yahoo.com.au> <E1KpNwq-0003OW-8f@pomaz-ex.szeredi.hu> <E1KpOOL-0003Vf-9y@pomaz-ex.szeredi.hu> <48F378C6.7030206@linux-foundation.org> <E1KpOjX-0003dt-AY@pomaz-ex.szeredi.hu> <48FC9CCC.3040006@linux-foundation.org> <E1Krz4o-0002Fi-Pu@pomaz-ex.szeredi.hu> <48FCCC72.5020202@linux-foundation.org> <E1KrzgK-0002QS-Os@pomaz-ex.szeredi.hu>
In-Reply-To: <E1KrzgK-0002QS-Os@pomaz-ex.szeredi.hu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: penberg@cs.helsinki.fi, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Miklos Szeredi wrote:

>> There is another call to invalidate_mapping_pages() in prune_icache (that is
>> where this code originates). No i_mutex and i_alloc. Only iprune_mutex held
>> and that seems to be for the protection of the list. So just checking
>> inode->i_count would do the trick?
> 
> Yes, that's what I was saying.

Ok. Thats easy to do.

> 
>>> The big issue is dealing with umount.  You could do something like
>>> grab_super() on sb before getting a ref on the inode/dentry.  But I'm
>>> not sure this is a good idea.  There must be a simpler way to achieve
>>> this..
>> Taking a lock on vfsmount_lock? But that would make dentry reclaim a pain.
> 
> No, I mean simpler than having to do this two stage stuff.

How could it be simpler? First you need to establish a secure reference to the
object so that it cannot vanish from under us. Then all the references can be
checked and possibly removed. If we do not need a secure reference then the
get_dentries() etc method can be NULL.

>> We are only interested in the reclaim a dentry if its currently unused. If so
>> then why does unmount matter? Both unmount and reclaim will attempt to remove
>> the dentry.
>>
>> Have a look at get_dentries(). It takes the dcache_lock and checks the dentry
>> state. Either the entry is ignored or dget_locked() removes it from the lru.
>> If its off the LRU then it can no longer be reclaimed by umount.
> 
> How is that better?  You will still get busy inodes on umount.

Those inodes are going to be freed by the reclaim code. Why would they be busy
(unless the case below occurs of course).

> And anyway the dentry could be put back onto the LRU by somebody else
> between get_dentries() and kick_dentries().  So I don't even see how
> taking the dentry off the LRU helps _anything_.

get_dentries() gets a reference. dput will not put the dentry back onto the LRU.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
