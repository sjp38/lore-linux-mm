Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8293D6B0284
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 17:18:14 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d6-v6so10587774plo.15
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 14:18:14 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o26-v6si15243620pge.307.2018.07.02.14.18.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 14:18:13 -0700 (PDT)
Date: Mon, 2 Jul 2018 14:18:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
Message-Id: <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
In-Reply-To: <CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
	<CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

On Mon, 2 Jul 2018 12:34:00 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Sun, Jul 1, 2018 at 10:52 PM Waiman Long <longman@redhat.com> wrote:
> >
> > A rogue application can potentially create a large number of negative
> > dentries in the system consuming most of the memory available if it
> > is not under the direct control of a memory controller that enforce
> > kernel memory limit.
> 
> I certainly don't mind the patch series, but I would like it to be
> accompanied with some actual example numbers, just to make it all a
> bit more concrete.
> 
> Maybe even performance numbers showing "look, I've filled the dentry
> lists with nasty negative dentries, now it's all slower because we
> walk those less interesting entries".
> 

(Please cc linux-mm@kvack.org on this work)

Yup.  The description of the user-visible impact of current behavior is
far too vague.

In the [5/6] changelog it is mentioned that a large number of -ve
dentries can lead to oom-killings.  This sounds bad - -ve dentries
should be trivially reclaimable and we shouldn't be oom-killing in such
a situation.

Dumb question: do we know that negative dentries are actually
worthwhile?  Has anyone checked in the past couple of decades?  Perhaps
our lookups are so whizzy nowadays that we don't need them?
