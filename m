Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE5746B0279
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:33:57 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id s5-v6so4594100plq.4
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 10:33:57 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id f21-v6si20885561pgl.235.2018.07.12.10.33.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Jul 2018 10:33:56 -0700 (PDT)
Message-ID: <1531416833.18255.10.camel@HansenPartnership.com>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 12 Jul 2018 10:33:53 -0700
In-Reply-To: <30ac8e9b-a48c-9c37-5a96-731ad214262b@redhat.com>
References: <1530905572-817-1-git-send-email-longman@redhat.com>
	 <20180709081920.GD22049@dhcp22.suse.cz>
	 <62275711-e01d-7dbe-06f1-bf094b618195@redhat.com>
	 <20180710142740.GQ14284@dhcp22.suse.cz>
	 <a2794bcc-9193-cbca-3a54-47420a2ab52c@redhat.com>
	 <20180711102139.GG20050@dhcp22.suse.cz>
	 <9f24c043-1fca-ee86-d609-873a7a8f7a64@redhat.com>
	 <1531330947.3260.13.camel@HansenPartnership.com>
	 <18c5cbfe-403b-bb2b-1d11-19d324ec6234@redhat.com>
	 <1531336913.3260.18.camel@HansenPartnership.com>
	 <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
	 <1531411494.18255.6.camel@HansenPartnership.com>
	 <30ac8e9b-a48c-9c37-5a96-731ad214262b@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>, Michal Hocko <mhocko@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On Thu, 2018-07-12 at 12:26 -0400, Waiman Long wrote:
> On 07/12/2018 12:04 PM, James Bottomley wrote:
> > On Thu, 2018-07-12 at 11:54 -0400, Waiman Long wrote:
> > > 
> > > It is not that dentry cache is harder to get rid of than the
> > > other memory. It is that the ability of generate unlimited number
> > > of negative dentries that will displace other useful memory from
> > > the system. What the patch is trying to do is to have a warning
> > > or notification system in place to spot unusual activities in
> > > regard to the number of negative dentries in the system. The
> > > system administrators can then decide on what to do next.
> > 
> > But every cache has this property: I can cause the same effect by
> > doing a streaming read on a multi gigabyte file: the page cache
> > will fill with the clean pages belonging to the file until I run
> > out of memory and it has to start evicting older cache
> > entries.A A Once we hit the steady state of minimal free memory, the
> > mm subsytem tries to balance the cache requests (like my streaming
> > read) against the existing pool of cached objects.
> > 
> > The question I'm trying to get an answer to is why does the dentry
> > cache need special limits when the mm handling of the page cache
> > (and other mm caches) just works?
> > 
> > James
> > 
> 
> I/O activities can be easily tracked.

Tracked?  What do you mean tracked?  you mean we can control the page
cache through userfaultfd or something without resorting to cgroup
limits or something different?  I mean all caches are "tracked" because
otherwise we wouldn't know whether we have to retrieve/generate the
object or pull it from the cache.  If it's just about cache state,
what's wrong with /proc/sys/fs/dentry-state?

>  Generation of negative dentries, however, is more insidious. So the
> ability to track and be notified when too many negative dentries are
> created can be a useful tool for the system administrators. Besides,
> there are paranoid users out there who want to have control of as
> much as system parameters as possible.

To what end?  what problem are these administrators trying to solve? 
You keep coming back to the circular argument that the problem they're
trying to solve is limiting negative dentries, but I want to know what
issue they see in their systems that causes them to ask for this knob.

James
