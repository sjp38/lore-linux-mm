Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id DA08C6B0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 11:51:28 -0400 (EDT)
Date: Wed, 10 Jul 2013 17:45:38 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/1] mm: mempolicy: fix mbind_range() && vma_adjust()
	interaction
Message-ID: <20130710154538.GA21145@redhat.com>
References: <1372901537-31033-1-git-send-email-ccross@android.com> <20130704202232.GA19287@redhat.com> <CAMbhsRRjGjo_-zSigmdsDvY-kfBhmP49bDQzsgHfj5N-y+ZAdw@mail.gmail.com> <20130708180424.GA6490@redhat.com> <20130708180501.GB6490@redhat.com> <20130709145645.bd48e31c1a7d9e83d521b845@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130709145645.bd48e31c1a7d9e83d521b845@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Colin Cross <ccross@android.com>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Hampson, Steven T" <steven.t.hampson@intel.com>, lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rusty Russell <rusty@rustcorp.com.au>, "Eric W. Biederman" <ebiederm@xmission.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Pekka Enberg <penberg@kernel.org>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

On 07/09, Andrew Morton wrote:
>
> On Mon, 8 Jul 2013 20:05:01 +0200 Oleg Nesterov <oleg@redhat.com> wrote:
>
> > Change mbind_range() to recheck mpol_equal() after vma_merge() to
> > fix the problem 1444f92c tried to address.
>
> So I assume the kernel still passes Steven's testcase from the
> 1444f92c changelog?

Yes.

Just in case, I had to modify it a little bit so that it can be compiled
on my machine. But this test-case is not reliable afaics. It should fail
(without 1444f92c or this fix) only if the subsequent get_unmapped_area()
allocates the region "right before" the previous mmap.

Please see the simplified and robust test-case below.

Oleg.

int main(void)
{
	unsigned long mask[MAXNODE] = { 1 };
	int pgsz = getpagesize();
	int policy = -1;
	unsigned char *p;

	p = mmap(NULL, 2 * pgsz, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS,
			-1, 0);
	assert(p != MAP_FAILED);

	assert(syscall(__NR_mbind, p + pgsz, pgsz, MPOL_BIND, mask, MAXNODE, 0) == 0);
	assert(syscall(__NR_mbind, p, pgsz, MPOL_BIND, mask, MAXNODE, 0) == 0);
	assert(syscall(__NR_get_mempolicy, &policy, NULL, 0, p, MPOL_F_ADDR) == 0);

	assert(policy == MPOL_BIND);
	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
