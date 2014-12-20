Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 23DD26B0032
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 19:06:51 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id y19so2583856wgg.7
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 16:06:50 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id mn7si20125172wjc.31.2014.12.19.16.06.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Dec 2014 16:06:50 -0800 (PST)
Date: Fri, 19 Dec 2014 16:06:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/zsmalloc: add statistics support
Message-Id: <20141219160648.5cea8a6b0c764caa6100a585@linux-foundation.org>
In-Reply-To: <20141219235852.GB11975@blaptop>
References: <1418993719-14291-1-git-send-email-opensource.ganesh@gmail.com>
	<20141219143244.1e5fabad8b6733204486f5bc@linux-foundation.org>
	<20141219233937.GA11975@blaptop>
	<20141219154548.3aa4cc02b3322f926aa4c1d6@linux-foundation.org>
	<20141219235852.GB11975@blaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Ganesh Mahendran <opensource.ganesh@gmail.com>, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 20 Dec 2014 08:58:52 +0900 Minchan Kim <minchan@kernel.org> wrote:

> On Fri, Dec 19, 2014 at 03:45:48PM -0800, Andrew Morton wrote:
> > On Sat, 20 Dec 2014 08:39:37 +0900 Minchan Kim <minchan@kernel.org> wrote:
> > 
> > > Then, we should fix debugfs_create_dir can return errno to propagate the error
> > > to end user who can know it was failed ENOMEM or EEXIST.
> > 
> > Impractical.  Every caller of every debugfs interface will need to be
> > changed!
> 
> If you don't like changing of all of current caller, maybe, we can define
> debugfs_create_dir_error and use it.
> 
> struct dentry *debugfs_create_dir_err(const char *name, struct dentry *parent, int *err)
> and tweak debugfs_create_dir.
> struct dentry *debugfs_create_dir(const char *name, struct dentry *parent, int *err)
> {
> 	..
> 	..
> 	if (error) {
> 		*err = error;
> 		dentry = NULL;
> 	}
> }
> 
> Why not?

It involves rehashing a lengthy argument with Greg.

> > 
> > It's really irritating and dumb.  What we're supposed to do is to
> > optionally report the failure, then ignore it.  This patch appears to
> > be OK in that respect.
> 
> At least, we should notify to the user why it was failed so he can fix
> the name if it was duplicated. So if you don't want debugfs, at least
> I want to warn all of reasons it can fail(at least, duplicated name)
> to the user.

Sure.  The debugfs interface design is mistaken.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
