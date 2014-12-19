Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id B150D6B0032
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 18:59:01 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id w10so2140371pde.11
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 15:59:01 -0800 (PST)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id gn10si11763572pbc.136.2014.12.19.15.58.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Dec 2014 15:59:00 -0800 (PST)
Received: by mail-pd0-f173.google.com with SMTP id ft15so2125961pdb.32
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 15:58:59 -0800 (PST)
Date: Sat, 20 Dec 2014 08:58:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm/zsmalloc: add statistics support
Message-ID: <20141219235852.GB11975@blaptop>
References: <1418993719-14291-1-git-send-email-opensource.ganesh@gmail.com>
 <20141219143244.1e5fabad8b6733204486f5bc@linux-foundation.org>
 <20141219233937.GA11975@blaptop>
 <20141219154548.3aa4cc02b3322f926aa4c1d6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141219154548.3aa4cc02b3322f926aa4c1d6@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ganesh Mahendran <opensource.ganesh@gmail.com>, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 19, 2014 at 03:45:48PM -0800, Andrew Morton wrote:
> On Sat, 20 Dec 2014 08:39:37 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > Then, we should fix debugfs_create_dir can return errno to propagate the error
> > to end user who can know it was failed ENOMEM or EEXIST.
> 
> Impractical.  Every caller of every debugfs interface will need to be
> changed!

If you don't like changing of all of current caller, maybe, we can define
debugfs_create_dir_error and use it.

struct dentry *debugfs_create_dir_err(const char *name, struct dentry *parent, int *err)
and tweak debugfs_create_dir.
struct dentry *debugfs_create_dir(const char *name, struct dentry *parent, int *err)
{
	..
	..
	if (error) {
		*err = error;
		dentry = NULL;
	}
}

Why not?

> 
> It's really irritating and dumb.  What we're supposed to do is to
> optionally report the failure, then ignore it.  This patch appears to
> be OK in that respect.

At least, we should notify to the user why it was failed so he can fix
the name if it was duplicated. So if you don't want debugfs, at least
I want to warn all of reasons it can fail(at least, duplicated name)
to the user.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
