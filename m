Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1772562012A
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 21:01:39 -0400 (EDT)
Subject: Re: scalability investigation: Where can I get your latest patches?
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <20100720031201.GC21274@amd>
References: <1278579387.2096.889.camel@ymzhang.sh.intel.com>
	 <20100720031201.GC21274@amd>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Wed, 04 Aug 2010 09:04:03 +0800
Message-Id: <1280883843.2125.20.camel@ymzhang.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: andi.kleen@intel.com, alexs.shi@intel.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-07-20 at 13:12 +1000, Nick Piggin wrote:
> On Thu, Jul 08, 2010 at 04:56:27PM +0800, Zhang, Yanmin wrote:
> > Nick,
> > 
> > I work with Andi Kleen and Tim to investigate some scalability issues.
> > 
> > Andi gave me a pointer at:
> > http://thread.gmane.org/gmane.linux.kernel/1002380/focus=42284
> > 
> > Where can I get your latest patches? It's better if I could get patch tarball.
> > 
> > Thanks,
> > Yanmin
> > 
> 
> Hi Yanmin,
> 
> Sorry for the delay. I have a git tree now, and it has been through
> some tress testing.
> 
> http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-npiggin.git
> 
> I would be very interested to know if you encounter problems or are
> able to generate any benchmark numbers.
Nick,

We ran lots of benchmarks on many machines. Below is something to share with you.

Improvement:
1) We get about 30% improvement with kbuild workload on Nehalem machines. It's hard
to improve kbuild performance. Your tree does.

Issues:
1) Compiling fails on a couple of file systems, such like CONFIG_ISO9660_FS=y.
2) dbenchthreads has about 50% regression. We connect a JBOD of 12 disks to
a machine. Start 4 dbench threads per disk.
We run the workload under a regular user account. If we run it under root account,
we get 22% improvement instead of regression.
The root cause is ACL checking. With your patch, do_path_lookup firstly goes through
rcu steps which including a exec permission checking. With ACL, the __exec_permission
always fails. Then a later nameidata_drop_rcu often fails as dentry->d_seq is changed.

With root account, it doesn't happen. We mount the working devices under /mnt/stp/XXX.
/mnt is of root user. So the exec permission check is ok.

I remount all file systems on the testing path with noacl option, and get the similar
results like under root account.

3) aim7 has about 40% regression on Nehalem EX 4-socket machine. The root cause is the
same thing like 2).

Other benchmarks' results have no improvement or regression.

Yanmin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
