Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 344466B00D6
	for <linux-mm@kvack.org>; Fri, 20 Nov 2009 11:41:27 -0500 (EST)
Date: Fri, 20 Nov 2009 17:41:10 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC][PATCH 1/2] perf: Add 'perf kmem' tool
Message-ID: <20091120164110.GA24183@elte.hu>
References: <4B064AF5.9060208@cn.fujitsu.com>
 <20091120081440.GA19778@elte.hu>
 <84144f020911200019p4978c8e8tc593334d974ee5ff@mail.gmail.com>
 <20091120083053.GB19778@elte.hu>
 <4B0657A4.2040606@cs.helsinki.fi>
 <4B06590C.7010109@cn.fujitsu.com>
 <20091120090353.GE19778@elte.hu>
 <20091120144215.GH18283@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091120144215.GH18283@ghostprotocols.net>
Sender: owner-linux-mm@kvack.org
To: Arnaldo Carvalho de Melo <acme@infradead.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <peterz@infradead.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Arnaldo Carvalho de Melo <acme@infradead.org> wrote:

> Em Fri, Nov 20, 2009 at 10:03:53AM +0100, Ingo Molnar escreveu:
> > 
> > * Li Zefan <lizf@cn.fujitsu.com> wrote:
> > 
> > > > (2) doing "perf kmem record" on machine A (think embedded here) and 
> > > > then "perf kmem report" on machine B. I haven't tried kmemtrace-user 
> > > > for a while but it did support both of them quite nicely at some 
> > > > point.
> > > 
> > > Everything needed and machine-specific will be recorded in perf.data, 
> > > so this should already been supported. I'll try it.
> > 
> > Right now the DSOs are not recorded in the perf.data - but it would be 
> > useful to add it and to turn perf.data into a self-sufficient capture of 
> > all relevant data, which can be analyzed on any box.
> 
> Well, the DSOs are recorded in perf.data, just not its symtabs, but now
> we have buildids, so we can ask for them to be installed on the other
> machine and it'll all work. Or should. :)
> 
> For instance:
> 
> [root@doppio linux-2.6-tip]# perf buildid-list -i perf.data | egrep 'vmlinux|nfs|libc-'
> ec8dd400904ddfcac8b1c343263a790f977159dc /lib64/libc-2.10.1.so
> 0da49504693a200583fda6f1b949e6d2f799e692 /usr/lib64/libnfsidmap_nsswitch.so.0.0.0
> c90269c87eaf08559012a9fa29f60780743360cd /usr/lib64/libnfsidmap.so.0.3.0
> 18e7cc53db62a7d35e9d6f6c9ddc23017d38ee9a vmlinux
> 3982866276471cde6ac5821fdced42a7b1bfd848 [nfs]
> 1489007276a50005753e730198fd93dd05b2082f [nfsd]
> 5a128f082fe7fdcab6fb5d1b71935accb1f34383 [nfs_acl]
> [root@doppio linux-2.6-tip]#
> 
> Now if I ask that the buildid for /usr/lib64/libnfsidmap.so.0.3.0 above
> to be installed, like this:
> 
> [root@doppio linux-2.6-tip]# yum install /usr/lib/debug/.build-id/c9/0269c87eaf08559012a9fa29f60780743360cd
> Loaded plugins: auto-update-debuginfo, refresh-packagekit
> Found 44 installed debuginfo package(s)
> Enabling fedora-debuginfo: Fedora 11 - x86_64 - Debug
> Reading repository metadata in from local files
> Enabling updates-debuginfo: Fedora 11 - x86_64 - Updates - Debug
> Reading repository metadata in from local files
> Setting up Install Process
> Importing additional filelist information
> Resolving Dependencies
> --> Running transaction check
> ---> Package nfs-utils-lib-debuginfo.x86_64 0:1.1.4-6.fc11 set to be updated
> --> Finished Dependency Resolution
> 
> Dependencies Resolved
> 
> ========================================================================
>  Package                   Arch   Version       Repository	 Size
> ========================================================================
> Installing:
>  nfs-utils-lib-debuginfo   x86_64 1.1.4-6.fc11  fedora-debuginfo 174 k
> 
> Transaction Summary
> ========================================================================
> Install       1 Package(s)
> Upgrade       0 Package(s)
> 
> Total download size: 174 k
> Is this ok [y/N]:
> 
> So now we have:
> 
> 1) 'perf record' records the build-ids into perf.data
> 2) 'perf buildid-list' list them, distro specific porcelain needed
>    to do the equivalent to the yum install above.
> 3) 'perf report' will only use the symtab in a file that has the matching
>    build-id, if a build-id is found in the perf.data header for a
>    particular DSO.
> 
> So we have a mechanism that is already present in several distros
> (build-id), that is in the kernel build process since ~2.6.23, and that
> avoids using mismatching DSOs when resolving symbols.

But what do we do if we have another box that runs say on a MIPS CPU, 
uses some minimal distro - and copy that perf.data over to an x86 box.

The idea is there to be some new mode of perf.data where all the 
relevant DSO contents (symtabs but also sections with instructions for 
perf annotate to work) are copied into perf.data, during or after data 
capture - on the box that does the recording.

Once we have everything embedded in the perf.data, analysis passes only 
have to work based on that particular perf.data - no external data.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
