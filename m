Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0186B029D
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 19:19:28 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h14-v6so38942pfi.19
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 16:19:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e98-v6si17380265plb.150.2018.07.02.16.19.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 16:19:27 -0700 (PDT)
Date: Mon, 2 Jul 2018 16:19:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
Message-Id: <20180702161925.1c717283dd2bd4a221bc987c@linux-foundation.org>
In-Reply-To: <1530570880.3179.9.camel@HansenPartnership.com>
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
	<CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
	<20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
	<1530570880.3179.9.camel@HansenPartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

On Mon, 02 Jul 2018 15:34:40 -0700 James Bottomley <James.Bottomley@HansenP=
artnership.com> wrote:

> On Mon, 2018-07-02 at 14:18 -0700, Andrew Morton wrote:
> > On Mon, 2 Jul 2018 12:34:00 -0700 Linus Torvalds <torvalds@linux-foun
> > dation.org> wrote:
> >=20
> > > On Sun, Jul 1, 2018 at 10:52 PM Waiman Long <longman@redhat.com>
> > > wrote:
> > > >=20
> > > > A rogue application can potentially create a large number of
> > > > negative
> > > > dentries in the system consuming most of the memory available if
> > > > it
> > > > is not under the direct control of a memory controller that
> > > > enforce
> > > > kernel memory limit.
> > >=20
> > > I certainly don't mind the patch series, but I would like it to be
> > > accompanied with some actual example numbers, just to make it all a
> > > bit more concrete.
> > >=20
> > > Maybe even performance numbers showing "look, I've filled the
> > > dentry
> > > lists with nasty negative dentries, now it's all slower because we
> > > walk those less interesting entries".
> > >=20
> >=20
> > (Please cc linux-mm@kvack.org on this work)
> >=20
> > Yup.=A0=A0The description of the user-visible impact of current behavior
> > is far too vague.
> >=20
> > In the [5/6] changelog it is mentioned that a large number of -ve
> > dentries can lead to oom-killings.=A0=A0This sounds bad - -ve dentries
> > should be trivially reclaimable and we shouldn't be oom-killing in
> > such a situation.
>=20
> If you're old enough, it's d=E9j=E0 vu; Andrea went on a negative dentry
> rampage about 15 years ago:
>=20
> https://lkml.org/lkml/2002/5/24/71

That's kinda funny.

> I think the summary of the thread is that it's not worth it because
> dentries are a clean cache, so they're immediately shrinkable.

Yes, "should be".  I could understand that the presence of huge
nunmbers of -ve dentries could result in undesirable reclaim of
pagecache, etc.  Triggering oom-killings is very bad, and presumably
has the same cause.

Before we go and add a large amount of code to do the shrinker's job
for it, we should get a full understanding of what's going wrong.  Is
it because the dentry_lru had a mixture of +ve and -ve dentries?=20
Should we have a separate LRU for -ve dentries?  Are we appropriately
aging the various dentries?  etc.

It could be that tuning/fixing the current code will fix whatever
problems inspired this patchset.

> > Dumb question: do we know that negative dentries are actually
> > worthwhile?=A0=A0Has anyone checked in the past couple of
> > decades?=A0=A0Perhaps our lookups are so whizzy nowadays that we don't
> > need them?
>=20
> There are still a lot of applications that keep looking up non-existent=20
> files, so I think it's still beneficial to keep them.  Apparently
> apache still looks for a .htaccess file in every directory it
> traverses, for instance.  Round tripping every one of these to disk
> instead of caching it as a negative dentry would seem to be a
> performance loser here.
>=20
> However, actually measuring this again might be useful.

Yup.  I don't know how hard it would be to disable the -ve dentries
(the rename thing makes it sounds harder than I expected) but having
real numbers to justify continuing presence might be a fun project for
someone.
