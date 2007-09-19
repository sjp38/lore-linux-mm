Date: Wed, 19 Sep 2007 10:23:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC/Patch](memory hotplug) fix null pointer access of
 kmem_cache_node after memory hotplug
In-Reply-To: <20070919095823.3770.Y-GOTO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0709191021110.11138@schroedinger.engr.sgi.com>
References: <20070918211932.0FFD.Y-GOTO@jp.fujitsu.com>
 <Pine.LNX.4.64.0709181200400.3351@schroedinger.engr.sgi.com>
 <20070919095823.3770.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007, Yasunori Goto wrote:

> build_zonelist() is called very early stage of bootstrap, But it is
> called final stage of hot-add.
> When build_zonelist() is called at hot-add, all kernel module can
> use new memory of the node. So, I'm afraid like following worst case.
> 
>    build_zonelist()              
>         :                     new_nodes_page = new_slab();
>         :                         :
>         :                         :
>         :                     discard_slab(new_nodes_page)
>         :                         (access kmem_cache_node)
>         :
>    kmem_cache_node setting,

So we cannot do this without holding off other kernel accesses since it is 
not serialized like bootstrap. Sigh.
 
> > > I think this "delay creation" fix is better way than it.
> > 
> > Looks like this is a way to on demand node structure creation?
> 
> Yes.

Could be useful in general if you can make that work reliably. We can just 
start out with a single per node structure for the boot node and then add 
others on demand?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
