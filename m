Date: Tue, 17 May 2005 23:20:07 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page
 migration-rc2 -- xfs-extended-attributes-rc2.patch
Message-Id: <20050517232007.018d52ab.pj@sgi.com>
In-Reply-To: <4289719A.20807@engr.sgi.com>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>
	<20050511043802.10876.60521.51027@jackhammer.engr.sgi.com>
	<20050511071538.GA23090@infradead.org>
	<4281F650.2020807@engr.sgi.com>
	<20050511125932.GW25612@wotan.suse.de>
	<42825236.1030503@engr.sgi.com>
	<20050511193207.GE11200@wotan.suse.de>
	<20050512104543.GA14799@infradead.org>
	<4289719A.20807@engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: hch@infradead.org, ak@suse.de, raybry@sgi.com, taka@valinux.co.jp, marcelo.tosatti@cyclades.com, haveblue@us.ibm.com, linux-mm@kvack.org, nathans@sgi.com, raybry@austin.rr.com, lhms-devel@lists.sourceforge.net, jes@wildopensource.com
List-ID: <linux-mm.kvack.org>

Ray wrote:
> If one were to use madvise() or mbind() to apply the migration
> policy flags ... then ... it's necessary to reach down to a common subobject,
> (such as the file struct, address space struct, or inode) and mark
> that.

As I wrote Ray offline earlier today (before noticing this thread), I
suggested considering adding another flag to fcntl(), not madvise/mbind,
since fcntl() is sometimes used to make changes to the underlying
in-core inode.

My rough idea was to have a S_SKIPMIGRATE flag in the in-core
inode->i_flag's, defaulting to off, which could be set and gotten via
fcntl on any file descriptor open on that inode.  The value set would
persist so long as some file held that dentry->inode open, or until
changed again.  Just before invoking the call to migrate a task, user
code could examine each named file mapped into the task, and by opening
each said file and performing the appropriate fcntl(), mark whether or
not pages from that mapped file should be migrated.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@engr.sgi.com> 1.650.933.1373, 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
