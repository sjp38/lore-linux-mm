Date: Fri, 08 Oct 2004 17:15:25 +0900 (JST)
Message-Id: <20041008.171525.17587512.taka@valinux.co.jp>
Subject: Re: [PATCH] mhp: transfer dirty tag at radix_tree_replace 
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20041006.163914.48665150.taka@valinux.co.jp>
References: <20041003.131338.41636688.taka@valinux.co.jp>
	<20041005164627.GB3462@logos.cnet>
	<20041006.163914.48665150.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marcelo.tosatti@cyclades.com
Cc: iwamoto@valinux.co.jp, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Marcelo.

> > > > 1) 
> > > > I'm pretty sure you should transfer the radix tree tag at radix_tree_replace().
> > > > If for example you transfer a dirty tagged page to another zone, an mpage_writepages()
> > > > will miss it (because it uses pagevec_lookup_tag(PAGECACHE_DIRTY_TAG)). 
> > > > 
> > > > Should be quite trivial to do (save tags before deleting and set to new entry, 
> > > > all in radix_tree_replace).
> > > > 
> > > > My implementation also contained the same bug.
> > > 
> > > Yes, it's one of the issues to do. The tag should be transferred in
> > > radix_tree_replace() as you pointed out. The current implementation
> > > sets the tag in set_page_dirty(newpage).
> > 
> > OK, guys, can you test this please?
> 
> Ok, I'll test it. 

It was sad that the patch couldn't be compiled because
PAGECACHE_TAG_DIRTY macro depended on the filesystem code.
I think radix_tree library shouldn't use it.

So that it would be better to make radix_tree_replace() accept tags
to be inherited or make the function from scratch.
So I decided to re-implement it and I'm testing it now.

> > This transfer the dirty radix tree tag at radix_tree_replace, avoiding 
> > a potential miss on tag-lookup.  We could also copy all bits representing 
> > the valid tags for this node in the radix tree. 
> > 
> > But this uses the available interfaces from radix-lib.c. In case 
> > a new tag gets added, radix_tree_replace() will have to know about it.
> 
> Yeah. I guess it would be better to copy the radix_tree_delete()
> code to radix_tree_replace() and modify it to replace items directly
> in the future.



void *radix_tree_replace(struct radix_tree_root *root,
                                        unsigned long index, void *item)
{
        struct radix_tree_path path[RADIX_TREE_MAX_PATH], *pathp = path;
        unsigned int height, shift;
        void *ret = NULL;

        height = root->height;
        if (index > radix_tree_maxindex(height))
                goto out;

        shift = (height - 1) * RADIX_TREE_MAP_SHIFT;
        pathp->node = NULL;
        pathp->slot = &root->rnode;

        while (height > 0) {
                int offset;

                if (*pathp->slot == NULL)
                        goto out;

                offset = (index >> shift) & RADIX_TREE_MAP_MASK;
                pathp[1].offset = offset;
                pathp[1].node = *pathp[0].slot;
                pathp[1].slot = (struct radix_tree_node **)
                                (pathp[1].node->slots + offset);
                pathp++;
                shift -= RADIX_TREE_MAP_SHIFT;
                height--;
        }

        if ((ret = *pathp[0].slot))
                *pathp[0].slot = item;
out:
        return ret;
}


Thank you,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
