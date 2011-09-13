Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id CED2C900136
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 16:52:26 -0400 (EDT)
Date: Tue, 13 Sep 2011 13:51:07 -0700
From: Andrew Morton <akpm@google.com>
Subject: Re: [PATCH V9 3/6] mm: frontswap: core frontswap functionality
Message-Id: <20110913135107.295aecfe.akpm@google.com>
In-Reply-To: <4E6FBFC4.1080901@linux.vnet.ibm.com>
References: <20110913174026.GA11298@ca-server1.us.oracle.com>
	<4E6FBFC4.1080901@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, konrad.wilk@oracle.com, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, chris.mason@oracle.com, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

On Tue, 13 Sep 2011 15:40:36 -0500
Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:

> Hey Dan,
> 
> I get the following compile warnings:
> 
> mm/frontswap.c: In function a??init_frontswapa??:
> mm/frontswap.c:264:5: warning: passing argument 4 of a??debugfs_create_size_ta?? from incompatible pointer type
> include/linux/debugfs.h:68:16: note: expected a??size_t *a?? but argument is of type a??long unsigned int *a??
> mm/frontswap.c:266:5: warning: passing argument 4 of a??debugfs_create_size_ta?? from incompatible pointer type
> include/linux/debugfs.h:68:16: note: expected a??size_t *a?? but argument is of type a??long unsigned int *a??
> mm/frontswap.c:268:5: warning: passing argument 4 of a??debugfs_create_size_ta?? from incompatible pointer type
> include/linux/debugfs.h:68:16: note: expected a??size_t *a?? but argument is of type a??long unsigned int *a??
> mm/frontswap.c:270:5: warning: passing argument 4 of a??debugfs_create_size_ta?? from incompatible pointer type
> include/linux/debugfs.h:68:16: note: expected a??size_t *a?? but argument is of type a??long unsigned int *a??
> 
> size_t is platform dependent but is generally "unsigned int"
> for 32-bit and "unsigned long" for 64-bit.
> 
> I think just typecasting these to size_t * would fix it.

That's very risky.

> On 09/13/2011 12:40 PM, Dan Magenheimer wrote:
> > +#ifdef CONFIG_DEBUG_FS
> > +	struct dentry *root = debugfs_create_dir("frontswap", NULL);
> > +	if (root == NULL)
> > +		return -ENXIO;
> > +	debugfs_create_size_t("gets", S_IRUGO,
> > +				root, &frontswap_gets);
> > +	debugfs_create_size_t("succ_puts", S_IRUGO,
> > +				root, &frontswap_succ_puts);
> > +	debugfs_create_size_t("puts", S_IRUGO,
> > +				root, &frontswap_failed_puts);
> > +	debugfs_create_size_t("invalidates", S_IRUGO,
> > +				root, &frontswap_invalidates);
> > +#endif

Make them u32 and use debugfs_create_x32(), perhaps.  Or create
debugfs_create_ulong().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
