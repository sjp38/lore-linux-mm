Message-ID: <428B55E3.1000201@engr.sgi.com>
Date: Wed, 18 May 2005 09:49:07 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page migration-rc2
 -- xfs-extended-attributes-rc2.patch
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>	<20050511043802.10876.60521.51027@jackhammer.engr.sgi.com>	<20050511071538.GA23090@infradead.org>	<4281F650.2020807@engr.sgi.com>	<20050511125932.GW25612@wotan.suse.de>	<42825236.1030503@engr.sgi.com>	<20050511193207.GE11200@wotan.suse.de>	<20050512104543.GA14799@infradead.org>	<4289719A.20807@engr.sgi.com> <20050517232007.018d52ab.pj@sgi.com>
In-Reply-To: <20050517232007.018d52ab.pj@sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: hch@infradead.org, ak@suse.de, raybry@sgi.com, taka@valinux.co.jp, marcelo.tosatti@cyclades.com, haveblue@us.ibm.com, linux-mm@kvack.org, nathans@sgi.com, raybry@austin.rr.com, lhms-devel@lists.sourceforge.net, jes@wildopensource.com
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Ray wrote:
> 
>>If one were to use madvise() or mbind() to apply the migration
>>policy flags ... then ... it's necessary to reach down to a common subobject,
>>(such as the file struct, address space struct, or inode) and mark
>>that.
> 
> 
> As I wrote Ray offline earlier today (before noticing this thread), I
> suggested considering adding another flag to fcntl(), not madvise/mbind,
> since fcntl() is sometimes used to make changes to the underlying
> in-core inode.
> 
> My rough idea was to have a S_SKIPMIGRATE flag in the in-core
> inode->i_flag's, defaulting to off, which could be set and gotten via
> fcntl on any file descriptor open on that inode.  The value set would
> persist so long as some file held that dentry->inode open, or until
> changed again.  Just before invoking the call to migrate a task, user
> code could examine each named file mapped into the task, and by opening
> each said file and performing the appropriate fcntl(), mark whether or
> not pages from that mapped file should be migrated.
> 

Actually, we need two flags:  S_SKIPMIGRATE, and S_MIGRATE_NON_SHARED.
I personally prefer using mbind() to set these attributes in the
address space object that maps a particular virtual address range,

I guess I don't see the advantage of invoking file system operations
to describe how memory should be dealt with in a migration operation.
So I'd prefer to keep all of the operations in the memory space, hence
mbind().

This makes sense to me since the migration operation is a policy issue,
and mbind() is in the business of setting memory policy.
-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
