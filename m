Date: Tue, 15 Aug 2006 15:07:21 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC][PATCH] "challenged" memory controller
Message-Id: <20060815150721.21ff961e.pj@sgi.com>
In-Reply-To: <20060815192047.EE4A0960@localhost.localdomain>
References: <20060815192047.EE4A0960@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dave@sr71.net
Cc: linux-mm@kvack.org, balbir@in.ibm.com
List-ID: <linux-mm.kvack.org>

Dave wrote:
> I've been toying with a little memory controller for the past
> few weeks, on and off.

I haven't actually thought about this much yet, but I suspect:

 1) This is missing some cpuset locking - look at the routine
    kernel/cpuset.c:__cpuset_memory_pressure_bump() for the
    locking required to reference current->cpuset, using task_lock().
    Notice that the current->cpuset reference is not valid once
    the task lock is dropped.

 2) This might not scale well, with a hot spot in the cpuset.  So
    far, I avoid any reference to the cpuset structure on hot code
    paths, especially any write references, but even read references,
    due to the above need for the task lock.

 3) There appears to be little sympathy for hanging memory controllers
    off the cpuset structure.  There is probably good technical reason
    for this; though at a minimum, the folks doing memory sharing
    controllers and the folks doing big honking NUMA iron placement have
    different perspectives.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
