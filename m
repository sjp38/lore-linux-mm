Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id A962A6B0035
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 17:11:09 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w61so5438055wes.29
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 14:11:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k9si2285170wiw.87.2014.03.31.14.11.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 31 Mar 2014 14:11:08 -0700 (PDT)
Date: Mon, 31 Mar 2014 23:11:06 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [next:master 15/486] fs/notify/fanotify/fanotify_user.c:214:23:
 error: 'struct fsnotify_event' has no member named 'fae'
Message-ID: <20140331211106.GF1367@quack.suse.cz>
References: <53384b3c.gyaYGJJFj2CNi4A/%fengguang.wu@intel.com>
 <20140331130931.96219b669e3333da9af6329b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140331130931.96219b669e3333da9af6329b@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

On Mon 31-03-14 13:09:31, Andrew Morton wrote:
> On Mon, 31 Mar 2014 00:50:04 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> > head:   201544be8c37dffbf069bb5fc9edb5674f8c1754
> > commit: a35f174ec04eaf07a52bb0603ecbb332450d6b4e [15/486] fanotify: use fanotify event structure for permission response processing
> > config: x86_64-randconfig-c0-0331 (attached as .config)
> > 
> > Note: the next/master HEAD 201544be8c37dffbf069bb5fc9edb5674f8c1754 builds fine.
> >       It only hurts bisectibility.
> > 
> > All error/warnings:
> > 
> >    fs/notify/fanotify/fanotify_user.c: In function 'copy_event_to_user':
> > >> fs/notify/fanotify/fanotify_user.c:214:23: error: 'struct fsnotify_event' has no member named 'fae'
> >       list_add_tail(&event->fae.fse.list,
> >                           ^
> > 
> > vim +214 fs/notify/fanotify/fanotify_user.c
> > 
> >    208			goto out_close_fd;
> >    209	
> >    210	#ifdef CONFIG_FANOTIFY_ACCESS_PERMISSIONS
> >    211		if (event->mask & FAN_ALL_PERM_EVENTS) {
> >    212			FANOTIFY_PE(event)->fd = fd;
> >    213			mutex_lock(&group->fanotify_data.access_mutex);
> >  > 214			list_add_tail(&event->fae.fse.list,
> >    215				      &group->fanotify_data.access_list);
> >    216			mutex_unlock(&group->fanotify_data.access_mutex);
> >    217		}
> 
> This, I suppose.
  Yup, that looks good. Thanks for fixing it up so quickly.

								Honza

> --- a/fs/notify/fanotify/fanotify_user.c~fanotify-use-fanotify-event-structure-for-permission-response-processing-fix
> +++ a/fs/notify/fanotify/fanotify_user.c
> @@ -209,9 +209,12 @@ static ssize_t copy_event_to_user(struct
>  
>  #ifdef CONFIG_FANOTIFY_ACCESS_PERMISSIONS
>  	if (event->mask & FAN_ALL_PERM_EVENTS) {
> -		FANOTIFY_PE(event)->fd = fd;
> +		struct fanotify_perm_event_info *pevent;
> +
> +		pevent = FANOTIFY_PE(event);
> +		pevent->fd = fd;
>  		mutex_lock(&group->fanotify_data.access_mutex);
> -		list_add_tail(&event->fae.fse.list,
> +		list_add_tail(&pevent->fae.fse.list,
>  			      &group->fanotify_data.access_list);
>  		mutex_unlock(&group->fanotify_data.access_mutex);
>  	}
> _
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
