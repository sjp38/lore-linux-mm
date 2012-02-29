Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 7C9A16B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 15:31:22 -0500 (EST)
Date: Wed, 29 Feb 2012 12:31:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH] fix move/migrate_pages() race on task struct
Message-Id: <20120229123120.127e21fd.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1202281329190.25590@router.home>
References: <20120223180740.C4EC4156@kernel>
	<alpine.DEB.2.00.1202231240590.9878@router.home>
	<4F468F09.5050200@linux.vnet.ibm.com>
	<alpine.DEB.2.00.1202231334290.10914@router.home>
	<4F469BC7.50705@linux.vnet.ibm.com>
	<alpine.DEB.2.00.1202231536240.13554@router.home>
	<m1ehtkapn9.fsf@fess.ebiederm.org>
	<alpine.DEB.2.00.1202240859340.2621@router.home>
	<4F47BF56.6010602@linux.vnet.ibm.com>
	<alpine.DEB.2.00.1202241053220.3726@router.home>
	<alpine.DEB.2.00.1202241105280.3726@router.home>
	<4F47C800.4090903@linux.vnet.ibm.com>
	<alpine.DEB.2.00.1202241131400.3726@router.home>
	<87sjhzun47.fsf@xmission.com>
	<alpine.DEB.2.00.1202271238450.32410@router.home>
	<87d390janv.fsf@xmission.com>
	<alpine.DEB.2.00.1202271636230.6435@router.home>
	<alpine.DEB.2.00.1202281329190.25590@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 28 Feb 2012 13:30:19 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> Migration functions perform the rcu_read_unlock too early. As a result the
> task pointed to may change from under us.
> 
> The following patch extend the period of the rcu_read_lock until after the
> permissions checks are done. We also take a refcount so that the task
> reference is stable when calling security check functions and performing
> cpuset node validation (which takes a mutex).
> 
> The refcount is dropped before actual page migration occurs so there is no
> change to the refcounts held during page migration.
> 
> Also move the determination of the mm of the task struct to immediately
> before the do_migrate*() calls so that it is clear that we switch from
> handling the task during permission checks to the mm for the actual
> migration. Since the determination is only done once and we then no longer
> use the task_struct we can be sure that we operate on a specific address
> space that will not change from under us.

What was the user-visible impact of the bug?

Please always include info this in bug fix changelogs - it helps me and
others to decide which kernel version(s) the patch should be merged
into.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
