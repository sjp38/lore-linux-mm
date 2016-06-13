Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 745236B0266
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 14:11:38 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id s1so276142744qkc.2
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 11:11:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t19si15912444qge.112.2016.06.13.11.11.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 11:11:37 -0700 (PDT)
Date: Mon, 13 Jun 2016 21:11:31 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] exit: clear TIF_MEMDIE after exit_task_work
Message-ID: <20160613210945-mutt-send-email-mst@redhat.com>
References: <20160301175431-mutt-send-email-mst@redhat.com>
 <20160301160813.GM9461@dhcp22.suse.cz>
 <20160301182027-mutt-send-email-mst@redhat.com>
 <20160301163537.GO9461@dhcp22.suse.cz>
 <20160301184046-mutt-send-email-mst@redhat.com>
 <20160301171758.GP9461@dhcp22.suse.cz>
 <20160301191906-mutt-send-email-mst@redhat.com>
 <20160314163943.GE11400@dhcp22.suse.cz>
 <20160607125014.GL12305@dhcp22.suse.cz>
 <20160613115041.GG6518@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160613115041.GG6518@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 13, 2016 at 01:50:41PM +0200, Michal Hocko wrote:
> On Tue 07-06-16 14:50:14, Michal Hocko wrote:
> > On Mon 14-03-16 17:39:43, Michal Hocko wrote:
> > > On Tue 01-03-16 19:20:24, Michael S. Tsirkin wrote:
> > > > On Tue, Mar 01, 2016 at 06:17:58PM +0100, Michal Hocko wrote:
> > > [...]
> > > > > Sorry, I could have been more verbose... The code would have to make sure
> > > > > that the mm is still alive before calling g-u-p by
> > > > > atomic_inc_not_zero(&mm->mm_users) and fail if the user count dropped to
> > > > > 0 in the mean time. See how fs/proc/task_mmu.c does that (proc_mem_open
> > > > > + m_start + m_stop.
> > > > > 
> > > > > The biggest advanatage would be that the mm address space pin would be
> > > > > only for the particular operation. Not sure whether that is possible in
> > > > > the driver though. Anyway pinning the mm for a potentially unbounded
> > > > > amount of time doesn't sound too nice.
> > > > 
> > > > Hmm that would be another atomic on data path ...
> > > > I'd have to explore that.
> > > 
> > > Did you have any chance to look into this?
> > 
> > So this is my take to get rid of mm_users pinning for an unbounded
> > amount of time. This is even not compile tested. I am not sure how to
> > handle when the mm goes away while there are still work items pending.
> > It seems this is not handled current anyway and only shouts with a
> > warning so this shouldn't cause a new regression AFAICS. I am not
> > familiar with the vnet code at all so I might be missing many things,
> > though. Does the below sound even remotely reasonable to you Michael?
> 
> I have checked the vnet code and it doesn't seem to rely on
> copy_from_user/get_user AFAICS. Other users of use_mm() need to copy to
> the userspace only as well.

E.g. vhost_get_vq_desc calls __get_user quite a lot.
I think it should be safe for it to fail, but
not to trigger warnings/errors.

> So we should be perfectly safe to OOM reap
> address space even when it is shared by the kthread [1] so this is
> not really needed for the OOM correctness purpose. It would be much
> nicer if the kthread didn't pin the mm for two long outside of the OOM
> handling as well of course but that lowers the priority of the change.
> 
> [1] http://lkml.kernel.org/r/20160613112348.GC6518@dhcp22.suse.cz
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
