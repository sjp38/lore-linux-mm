Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 05A8E6B0071
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 09:16:32 -0400 (EDT)
Received: by lagv1 with SMTP id v1so80016338lag.3
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 06:16:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q7si2979300wix.4.2015.04.17.06.16.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Apr 2015 06:16:30 -0700 (PDT)
Date: Fri, 17 Apr 2015 15:16:28 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC 1/4] fs: Add generic file system event notifications
Message-ID: <20150417131628.GA21539@quack.suse.cz>
References: <1429082147-4151-1-git-send-email-b.michalska@samsung.com>
 <1429082147-4151-2-git-send-email-b.michalska@samsung.com>
 <20150417113110.GD3116@quack.suse.cz>
 <553104E5.2040704@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <553104E5.2040704@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Beata Michalska <b.michalska@samsung.com>
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, linux-api@vger.kernel.org

On Fri 17-04-15 15:04:37, Beata Michalska wrote:
> On 04/17/2015 01:31 PM, Jan Kara wrote:
> > On Wed 15-04-15 09:15:44, Beata Michalska wrote:
> > Also I think that we should make it clear that each event type has
> > different set of arguments. For threshold events they'll be L1 & L2, for
> > other events there may be no arguments, for other events maybe something
> > else...
> > 
> 
> Currently only the threshold events use arguments -  not sure what arguments
> could be used for the remaining notifications. But any suggestions are welcomed.
  Me neither be someone will surely find something in future ;)

> > ...
> >> +static const match_table_t fs_etypes = {
> >> +	{ FS_EVENT_INFO,    "info"  },
> >> +	{ FS_EVENT_WARN,    "warn"  },
> >> +	{ FS_EVENT_THRESH,  "thr"   },
> >> +	{ FS_EVENT_ERR,     "err"   },
> >> +	{ 0, NULL },
> >> +};
> >   Why are there these generic message types? Threshold messages make good
> > sense to me. But not so much the rest. If they don't have a clear meaning,
> > it will be a mess. So I also agree with a message like - "filesystem has
> > trouble, you should probably unmount and run fsck" - that's fine. But
> > generic "info" or "warning" doesn't really carry any meaning on its own and
> > thus seems pretty useless to me. To explain a bit more, AFAIU this
> > shouldn't be a generic logging interface where something like severity
> > makes sense but rather a relatively specific interface notifying about
> > events in filesystem userspace should know about so I expect relatively low
> > number of types of events, not tens or even hundreds...
> > 
> 
> Getting rid of those would simplify the configuration part, indeed.
> So we would be left with 'generic' and threshold events.
> I guess I've overdone this part.
  Well, I would avoid defining anything that's not really used. So
currently you can define threshold events and we start with just those.
When someone hooks up filesystem error paths to send notification, we can
create event type for telling "filesystem corrupted". And so on... We just
have to be careful to document that new event types can be added and
userspace has to ignore events it does not understand.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
