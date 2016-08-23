Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6246B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 12:33:00 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 93so249135444qtg.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 09:33:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p102si1194959qkh.193.2016.08.23.09.32.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 09:32:59 -0700 (PDT)
Date: Tue, 23 Aug 2016 18:32:34 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2] kernel/fork: fix CLONE_CHILD_CLEARTID regression in
	nscd
Message-ID: <20160823163233.GA7123@redhat.com>
References: <1471968749-26173-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471968749-26173-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Roland McGrath <roland@hack.frob.com>, Andreas Schwab <schwab@suse.com>, William Preston <wpreston@suse.com>

On 08/23, Michal Hocko wrote:
>
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -913,14 +913,11 @@ void mm_release(struct task_struct *tsk, struct mm_struct *mm)
>  	deactivate_mm(tsk, mm);
>  
>  	/*
> -	 * If we're exiting normally, clear a user-space tid field if
> -	 * requested.  We leave this alone when dying by signal, to leave
> -	 * the value intact in a core dump, and to save the unnecessary
> -	 * trouble, say, a killed vfork parent shouldn't touch this mm.
> -	 * Userland only wants this done for a sys_exit.
> +	 * Signal userspace if we're not exiting with a core dump
> +	 * or a killed vfork parent which shouldn't touch this mm.

Well. ACK, but the comment looks wrong...

The "killed vfork parent ..." part should be removed, as you pointed
out this is no longer true.

OTOH, to me it would be better to not remove the "leave the value
intact in a core dump" part, otherwise the " we're not exiting with
a core dump" looks pointless because SIGNAL_GROUP_COREDUMP is self-
documenting.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
