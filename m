Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 43F426B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 10:57:31 -0500 (EST)
Date: Wed, 30 Jan 2013 10:57:18 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 1/8] mm: cleancache: lazy initialization to allow tmem
 backends to build/run as modules
Message-ID: <20130130155718.GB1272@konrad-lan.dumpdata.com>
References: <1352919432-9699-1-git-send-email-konrad.wilk@oracle.com>
 <1352919432-9699-2-git-send-email-konrad.wilk@oracle.com>
 <20121116151049.244bb8f4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121116151049.244bb8f4.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, minchan@kernel.org, mgorman@suse.de, fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com

On Fri, Nov 16, 2012 at 03:10:49PM -0800, Andrew Morton wrote:
> On Wed, 14 Nov 2012 13:57:05 -0500
> Konrad Rzeszutek Wilk <konrad.wilk@oracle.com> wrote:
> 
> > From: Dan Magenheimer <dan.magenheimer@oracle.com>
> > 
> > With the goal of allowing tmem backends (zcache, ramster, Xen tmem) to be
> > built/loaded as modules rather than built-in and enabled by a boot parameter,
> > this patch provides "lazy initialization", allowing backends to register to
> > cleancache even after filesystems were mounted. Calls to init_fs and
> > init_shared_fs are remembered as fake poolids but no real tmem_pools created.
> > On backend registration the fake poolids are mapped to real poolids and
> > respective tmem_pools.
> 
> What is your merge plan/path for this work?
> 
> >
> > ...
> >
> > + * When no backend is registered all calls to init_fs and init_shard_fs
> 
> "init_shared_fs"
> 
> > + * are registered and fake poolids are given to the respective
> > + * super block but no tmem_pools are created. When a backend
> > + * registers with cleancache the previous calls to init_fs and
> > + * init_shared_fs are executed to create tmem_pools and set the
> > + * respective poolids. While no backend is registered all "puts",
> > + * "gets" and "flushes" are ignored or fail.
> 
> The comment could use all 80 cols..
> 
> >
> > ...
> >
> >  struct cleancache_ops cleancache_register_ops(struct cleancache_ops *ops)
> >  {
> >  	struct cleancache_ops old = cleancache_ops;
> > +	int i;
> >  
> >  	cleancache_ops = *ops;
> > -	cleancache_enabled = 1;
> > +
> > +	backend_registered = true;
> > +	for (i = 0; i < MAX_INITIALIZABLE_FS; i++) {
> > +		if (fs_poolid_map[i] == FS_NO_BACKEND)
> > +			fs_poolid_map[i] = (*cleancache_ops.init_fs)(PAGE_SIZE);
> > +		if (shared_fs_poolid_map[i] == FS_NO_BACKEND)
> > +			shared_fs_poolid_map[i] = (*cleancache_ops.init_shared_fs)
> > +					(uuids[i], PAGE_SIZE);
> > +	}
> >  	return old;
> >  }
> 
> I never noticed before - this function returns a large structure by
> value.  That's really really unusual in the kernel.  I see no problem
> with it per-se, but it might generate awful code.
> 
> Also, this function has no locking and is blatantly racy.
> 
> >  EXPORT_SYMBOL(cleancache_register_ops);
> > @@ -61,15 +91,38 @@ EXPORT_SYMBOL(cleancache_register_ops);
> >  /* Called by a cleancache-enabled filesystem at time of mount */
> >  void __cleancache_init_fs(struct super_block *sb)
> >  {
> > -	sb->cleancache_poolid = (*cleancache_ops.init_fs)(PAGE_SIZE);
> > +	int i;
> > +
> > +	for (i = 0; i < MAX_INITIALIZABLE_FS; i++) {
> > +		if (fs_poolid_map[i] == FS_UNKNOWN) {
> > +			sb->cleancache_poolid = i + FAKE_FS_POOLID_OFFSET;
> > +			if (backend_registered)
> > +				fs_poolid_map[i] = (*cleancache_ops.init_fs)(PAGE_SIZE);
> > +			else
> > +				fs_poolid_map[i] = FS_NO_BACKEND;
> > +			break;
> > +		}
> > +	}
> >  }
> >  EXPORT_SYMBOL(__cleancache_init_fs);
> 
> This also looks wildly racy.
> 
> >  /* Called by a cleancache-enabled clustered filesystem at time of mount */
> >  void __cleancache_init_shared_fs(char *uuid, struct super_block *sb)
> >  {
> > -	sb->cleancache_poolid =
> > -		(*cleancache_ops.init_shared_fs)(uuid, PAGE_SIZE);
> > +	int i;
> > +
> > +	for (i = 0; i < MAX_INITIALIZABLE_FS; i++) {
> > +		if (shared_fs_poolid_map[i] == FS_UNKNOWN) {
> > +			sb->cleancache_poolid = i + FAKE_SHARED_FS_POOLID_OFFSET;
> > +			uuids[i] = uuid;
> > +			if (backend_registered)
> > +				shared_fs_poolid_map[i] = (*cleancache_ops.init_shared_fs)
> > +						(uuid, PAGE_SIZE);
> > +			else
> > +				shared_fs_poolid_map[i] = FS_NO_BACKEND;
> > +			break;
> > +		}
> > +	}
> >  }
> >  EXPORT_SYMBOL(__cleancache_init_shared_fs);
> 
> Again, a huge mess if two threads execute this concurrently.
> 
> > @@ -99,6 +152,19 @@ static int cleancache_get_key(struct inode *inode,
> >  }
> >  
> >  /*
> > + * Returns a pool_id that is associated with a given fake poolid.
> 
> Was there a comment anywhere which tells the reader what a "fake poolid" is?
> 
> > + */
> > +static int get_poolid_from_fake(int fake_pool_id)
> > +{
> > +	if (fake_pool_id >= FAKE_SHARED_FS_POOLID_OFFSET)
> > +		return shared_fs_poolid_map[fake_pool_id -
> > +			FAKE_SHARED_FS_POOLID_OFFSET];
> > +	else if (fake_pool_id >= FAKE_FS_POOLID_OFFSET)
> > +		return fs_poolid_map[fake_pool_id - FAKE_FS_POOLID_OFFSET];
> > +	return FS_NO_BACKEND;
> > +}
> > +
> > +/*
> >   * "Get" data from cleancache associated with the poolid/inode/index
> >   * that were specified when the data was put to cleanache and, if
> >   * successful, use it to fill the specified page with data and return 0.
> > @@ -109,17 +175,26 @@ int __cleancache_get_page(struct page *page)
> >  {
> >  	int ret = -1;
> >  	int pool_id;
> > +	int fake_pool_id;
> >  	struct cleancache_filekey key = { .u.key = { 0 } };
> >  
> > +	if (!backend_registered) {
> > +		cleancache_failed_gets++;
> > +		goto out;
> > +	}
> 
> Races everywhere...
> 
> >  	VM_BUG_ON(!PageLocked(page));
> > -	pool_id = page->mapping->host->i_sb->cleancache_poolid;
> > -	if (pool_id < 0)
> > +	fake_pool_id = page->mapping->host->i_sb->cleancache_poolid;
> > +	if (fake_pool_id < 0)
> >  		goto out;
> > +	pool_id = get_poolid_from_fake(fake_pool_id);
> >  
> >  	if (cleancache_get_key(page->mapping->host, &key) < 0)
> >  		goto out;
> >  
> > -	ret = (*cleancache_ops.get_page)(pool_id, key, page->index, page);
> > +	if (pool_id >= 0)
> > +		ret = (*cleancache_ops.get_page)(pool_id,
> > +				key, page->index, page);
> >  	if (ret == 0)
> >  		cleancache_succ_gets++;
> >  	else
> > @@ -138,12 +213,23 @@ EXPORT_SYMBOL(__cleancache_get_page);
> >  void __cleancache_put_page(struct page *page)
> >  {
> >  	int pool_id;
> > +	int fake_pool_id;
> >  	struct cleancache_filekey key = { .u.key = { 0 } };
> >  
> > +	if (!backend_registered) {
> > +		cleancache_puts++;
> > +		return;
> > +	}
> 
> More..
> 
> >  	VM_BUG_ON(!PageLocked(page));
> > -	pool_id = page->mapping->host->i_sb->cleancache_poolid;
> > +	fake_pool_id = page->mapping->host->i_sb->cleancache_poolid;
> > +	if (fake_pool_id < 0)
> > +		return;
> > +
> > +	pool_id = get_poolid_from_fake(fake_pool_id);
> > +
> >  	if (pool_id >= 0 &&
> > -	      cleancache_get_key(page->mapping->host, &key) >= 0) {
> > +		cleancache_get_key(page->mapping->host, &key) >= 0) {
> >  		(*cleancache_ops.put_page)(pool_id, key, page->index, page);
> >  		cleancache_puts++;
> >  	}
> >
> > ...
> >
> 
> I don't understand the timing flow here, nor the existing constraints
> on what can be done and when, but....
> 
> The whole thing looks really hacky?  Why do we need to remember all
> this stuff for later on?  What prevents us from simply synchonously
> doing whatever we need to do when someone wants to register a backend?
> 
> Maybe a little ascii time chart/flow diagram would help.

This patch hopefully answers the questions and comments. It has a bit
of a a), then b), then c) type chart to illustrate the issue of backends
registered asynchronously.
