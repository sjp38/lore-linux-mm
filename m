Date: Thu, 20 Sep 2007 11:06:47 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [RFC/Patch](memory hotplug) fix null pointer access of kmem_cache_node after memory hotplug
In-Reply-To: <Pine.LNX.4.64.0709191021110.11138@schroedinger.engr.sgi.com>
References: <20070919095823.3770.Y-GOTO@jp.fujitsu.com> <Pine.LNX.4.64.0709191021110.11138@schroedinger.engr.sgi.com>
Message-Id: <20070920095443.08D5.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 19 Sep 2007, Yasunori Goto wrote:
> 
> > build_zonelist() is called very early stage of bootstrap, But it is
> > called final stage of hot-add.
> > When build_zonelist() is called at hot-add, all kernel module can
> > use new memory of the node. So, I'm afraid like following worst case.
> > 
> >    build_zonelist()              
> >         :                     new_nodes_page = new_slab();
> >         :                         :
> >         :                         :
> >         :                     discard_slab(new_nodes_page)
> >         :                         (access kmem_cache_node)
> >         :
> >    kmem_cache_node setting,
> 
> So we cannot do this without holding off other kernel accesses since it is 
> not serialized like bootstrap. Sigh.
>
> > > > I think this "delay creation" fix is better way than it.
> > > 
> > > Looks like this is a way to on demand node structure creation?
> > 
> > Yes.
> 
> Could be useful in general if you can make that work reliably. We can just 
> start out with a single per node structure for the boot node and then add 
> others on demand?

Hmmmmm. I don't think demand node creation can be generic.
Just I would like to fix the panic.
Ok, I'll make a patch which sets kmem_cache_node before
build_zonelist() to fix panic for the present.
And I reconsider about allocation place issue later.

Thanks for your comment.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
