Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 4F1A96B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 12:45:28 -0400 (EDT)
Date: Tue, 18 Jun 2013 11:45:37 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCH v2] Make transparent hugepages cpuset aware
Message-ID: <20130618164537.GJ16067@sgi.com>
References: <1370967244-5610-1-git-send-email-athorlton@sgi.com>
 <alpine.DEB.2.02.1306111517200.6141@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306111517200.6141@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>

On Tue, Jun 11, 2013 at 03:20:09PM -0700, David Rientjes wrote:
> On Tue, 11 Jun 2013, Alex Thorlton wrote:
> 
> > This patch adds the ability to control THPs on a per cpuset basis.
> > Please see
> > the additions to Documentation/cgroups/cpusets.txt for more
> > information.
> > 
> 
> What's missing from both this changelog and the documentation you
> point to 
> is why this change is needed.
> 
> I can understand how you would want a subset of processes to not use
> thp 
> when it is enabled.  This is typically where MADV_NOHUGEPAGE is used
> with 
> some type of malloc hook.
> 
> I don't think we need to do this on a cpuset level, so unfortunately I 
> think this needs to be reworked.  Would it make sense to add a
> per-process 
> tunable to always get MADV_NOHUGEPAGE behavior for all of its sbrk()
> and 
> mmap() calls?  Perhaps, but then you would need to justify why it
> can't be 
> done with a malloc hook in userspace.
> 
> This seems to just be working around a userspace issue or for a matter
> of 
> convenience, right?

David,

Thanks for your input, however, I believe the method of using a malloc
hook falls apart when it comes to static binaries, since we wont' have
any shared libraries to hook into.  Although using a malloc hook is a
perfectly suitable solution for most cases, we're looking to implement a
solution that can be used in all situations.

Aside from that particular shortcoming of the malloc hook solution,
there are some other situations having a cpuset-based option is a
much simpler and more efficient solution than the alternatives.  One
such situation that comes to mind would be an environment where a batch
scheduler is in use to ration system resources.  If an administrator
determines that a users jobs run more efficiently with thp always on,
the administrator can simply set the users jobs to always run with that
setting, instead of having to coordinate with that user to get them to
run their jobs in a different way.  I feel that, for cases such as this,
the this additional flag is in line with the other capabilities that
cgroups and cpusets provide.

While there are likely numerous other situations where having a flag to
control thp on the cpuset level makes things a bit easier to manage, the
one real show-stopper here is that we really have no other options when
it comes to static binaries.

- Alex Thorlton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
