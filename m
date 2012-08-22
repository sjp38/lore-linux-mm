Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 706246B005D
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 09:22:50 -0400 (EDT)
Date: Wed, 22 Aug 2012 09:22:43 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v3 13/17] lockd: use new hashtable implementation
Message-ID: <20120822132243.GA2844@Krystal>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com> <1345602432-27673-14-git-send-email-levinsasha928@gmail.com> <20120822114752.GC20158@fieldses.org> <5034CD02.2010103@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5034CD02.2010103@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

* Sasha Levin (levinsasha928@gmail.com) wrote:
> On 08/22/2012 01:47 PM, J. Bruce Fields wrote:
> > On Wed, Aug 22, 2012 at 04:27:08AM +0200, Sasha Levin wrote:
> >> +static int __init nlm_init(void)
> >> +{
> >> +	hash_init(nlm_files);
> >> +	return 0;
> >> +}
> >> +
> >> +module_init(nlm_init);
> > 
> > That's giving me:
> > 
> > fs/lockd/svcsubs.o: In function `nlm_init':
> > /home/bfields/linux-2.6/fs/lockd/svcsubs.c:454: multiple definition of `init_module'
> > fs/lockd/svc.o:/home/bfields/linux-2.6/fs/lockd/svc.c:606: first defined here
> > make[2]: *** [fs/lockd/lockd.o] Error 1
> > make[1]: *** [fs/lockd] Error 2
> > make[1]: *** Waiting for unfinished jobs....
> 
> I tested this entire patch set both with linux-next and Linus' latest master,
> and it worked fine in both places.
> 
> Is it possible that lockd has a -next tree which isn't pulled into linux-next?
> (there's nothing listed in MAINTAINERS that I could see).

fs/lockd/Makefile:

obj-$(CONFIG_LOCKD) += lockd.o

lockd-objs-y := clntlock.o clntproc.o clntxdr.o host.o svc.o svclock.o \
                svcshare.o svcproc.o svcsubs.o mon.o xdr.o grace.o

your patch adds a module_init to svcsubs.c.
However, there is already one in svc.c, pulled into the same module.

in your test build, is CONFIG_LOCKD defined as "m" or "y" ? You should
always test both.

One solution here is to create a "local" init function in svcsubs.c and
expose it to svc.c, so the latter can call it from its module init
function.

Thanks,

Mathieu

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
