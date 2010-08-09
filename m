Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F0E5F6B02A4
	for <linux-mm@kvack.org>; Sun,  8 Aug 2010 22:36:04 -0400 (EDT)
Subject: Re: scalability investigation: Where can I get your latest patches?
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <20100805114438.GA9547@amd>
References: <1278579387.2096.889.camel@ymzhang.sh.intel.com>
	 <20100720031201.GC21274@amd>
	 <1280883843.2125.20.camel@ymzhang.sh.intel.com> <20100805114438.GA9547@amd>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 09 Aug 2010 10:36:29 +0800
Message-Id: <1281321389.2125.96.camel@ymzhang.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: andi.kleen@intel.com, alex.shi@intel.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2010-08-05 at 21:44 +1000, Nick Piggin wrote:
> On Wed, Aug 04, 2010 at 09:04:03AM +0800, Zhang, Yanmin wrote:
> > We ran lots of benchmarks on many machines. Below is something to
> > share with you.
> > 
> > Improvement:
> > 1) We get about 30% improvement with kbuild workload on Nehalem
> > machines. It's hard to improve kbuild performance. Your tree does.
> > 
> > Issues:
> > 1) Compiling fails on a couple of file systems, such like CONFIG_ISO9660_FS=y.
> > 2) dbenchthreads has about 50% regression. We connect a JBOD of 12 disks to
> > a machine. Start 4 dbench threads per disk.  We run the workload under
> > a regular user account. If we run it under root account, we get 22%
> > improvement instead of regression.  The root cause is ACL checking.
> > With your patch, do_path_lookup firstly goes through rcu steps which
> > including a exec permission checking. With ACL, the __exec_permission
> > always fails. Then a later nameidata_drop_rcu often fails as
> > dentry->d_seq is changed.
> 
> Oh one other thing I wanted to ask about. d_seq changing should not
> be too common. If the directory is renamed, or if it is turned negative
> should be the only cases in which we should see a d_seq changes.
> 
> Or unless there is a bug and it is checking the wrong sequence or
> against the wrong dentry. 
Sorry for misleading you. It fails at the beginning in nameidata_drop_rcu
because (nd->flags & LOOKUP_FIRST) is true.

> How often would you say nameidata_drop_rcu
> fails (without the following acl rcu patches)?
I instrument kernel and find nameidata_drop_rcu always fails.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
