Date: 7 Jan 2005 00:04:19 +0100
Date: Fri, 7 Jan 2005 00:04:19 +0100
From: Andi Kleen <ak@muc.de>
Subject: Re: page migration patchset
Message-ID: <20050106230419.GA26074@muc.de>
References: <41DDA6CB.6050307@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <41DDA6CB.6050307@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Paul Jackson <pj@sgi.com>, Steve Longerbeam <stevel@mwwireless.net>, Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 06, 2005 at 02:59:55PM -0600, Ray Bryant wrote:
> Now I know there is no locking protection around the mems_allowed
> bitmask, so changing this while the process is still running
> sounds hard.  But part of the plan I am working under assumes
> that the process is stopped before it is migrated.  (Shared
> pages that are only shared among processes all of whom are to be
> moved would similarly be handled; pages shsared among migrated
> and non-migrated processes, e. g. glibc pages, would not
> typically need to be moved at all, since they likely reside
> somewhere outside the set of nodes to be migrated from.)
> 
> But if the process is suspended, isn't all that is needed just
> to do the obvious translation on the mems_allowed vector?

Probably yes. But I can't say for sure since I haven't followed
the design and code of mems_allowed very closely
(it's not in mainline and seems to be only added with the cpumemset
patches). I would take Paul's word more seriously than mine 
on that. 

I assume you stop the process while doing page migration,
and while a process is stopped it should be safe to touch
task_struct fields as long as you lock against yourself.

> (Similarly for the dedicated node stuff, I forget the name for
> that at the moment...)

You mean NUMA API? You would need to modify all the mempolicy
data structures.

They can be safely changed when the mm semaphore is hold. 
However such policies can be attached to files too (e.g. 
in tmpfs) with no association with a process. There are plans
to allow them at arbitary files.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
