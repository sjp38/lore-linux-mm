Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0FDFA6B0038
	for <linux-mm@kvack.org>; Wed, 24 Aug 2016 04:10:27 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so6028322lfe.0
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 01:10:26 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id e73si7857878wma.8.2016.08.24.01.10.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Aug 2016 01:10:25 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id o80so1478128wme.0
        for <linux-mm@kvack.org>; Wed, 24 Aug 2016 01:10:25 -0700 (PDT)
Date: Wed, 24 Aug 2016 10:10:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] kernel/fork: fix CLONE_CHILD_CLEARTID regression in
 nscd
Message-ID: <20160824081023.GE31179@dhcp22.suse.cz>
References: <1471968749-26173-1-git-send-email-mhocko@kernel.org>
 <20160823163233.GA7123@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160823163233.GA7123@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Roland McGrath <roland@hack.frob.com>, Andreas Schwab <schwab@suse.com>, William Preston <wpreston@suse.com>

On Tue 23-08-16 18:32:34, Oleg Nesterov wrote:
> On 08/23, Michal Hocko wrote:
> >
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -913,14 +913,11 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
> >  	deactivate_mm(tsk, mm);
> >  
> >  	/*
> > -	 * If we're exiting normally, clear a user-space tid field if
> > -	 * requested.  We leave this alone when dying by signal, to leave
> > -	 * the value intact in a core dump, and to save the unnecessary
> > -	 * trouble, say, a killed vfork parent shouldn't touch this mm.
> > -	 * Userland only wants this done for a sys_exit.
> > +	 * Signal userspace if we're not exiting with a core dump
> > +	 * or a killed vfork parent which shouldn't touch this mm.
> 
> Well. ACK, but the comment looks wrong...
> 
> The "killed vfork parent ..." part should be removed, as you pointed
> out this is no longer true.
> 
> OTOH, to me it would be better to not remove the "leave the value
> intact in a core dump" part, otherwise the " we're not exiting with
> a core dump" looks pointless because SIGNAL_GROUP_COREDUMP is self-
> documenting.

Sounds better?
diff --git a/kernel/fork.c b/kernel/fork.c
index b89f0eb99f0a..ddde5849df81 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -914,7 +914,8 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
 
 	/*
 	 * Signal userspace if we're not exiting with a core dump
-	 * or a killed vfork parent which shouldn't touch this mm.
+	 * because we want to leave the value intact for debugging
+	 * purposes.
 	 */
 	if (tsk->clear_child_tid) {
 		if (!(tsk->signal->flags & SIGNAL_GROUP_COREDUMP) &&
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
