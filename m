Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 217736B0027
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 04:13:20 -0400 (EDT)
Date: Mon, 8 Apr 2013 09:13:16 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: NUMA Autobalancing Kernel 3.8
Message-ID: <20130408081316.GB2623@suse.de>
References: <515A87C3.1000309@profihost.ag>
 <20130402104844.GE32241@suse.de>
 <515AC3EE.1030803@profihost.ag>
 <20130402125408.GG32241@suse.de>
 <515AEC71.9020704@profihost.ag>
 <20130403140344.GA5811@suse.de>
 <515C388C.5040903@profihost.ag>
 <20130405120034.GA2623@suse.de>
 <515EBF38.8040804@profihost.ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <515EBF38.8040804@profihost.ag>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, srikar@linux.vnet.ibm.com, aarcange@redhat.com, mingo@kernel.org, riel@redhat.com

On Fri, Apr 05, 2013 at 02:10:32PM +0200, Stefan Priebe - Profihost AG wrote:
> Am 05.04.2013 14:00, schrieb Mel Gorman:
> > On Wed, Apr 03, 2013 at 04:11:24PM +0200, Stefan Priebe - Profihost AG wrote:
> >> Am 03.04.2013 16:03, schrieb Mel Gorman:
> >>>> I've now tested 3.9-rc5 this gaves me a slightly different kernel log:
> >>>> [  197.236518] pigz[2908]: segfault at 0 ip           (null) sp
> >>>> 00007f347bffed00 error 14
> >>>> [  197.237632] traps: pigz[2915] general protection ip:7f3482dbce2d
> >>>> sp:7f3473ffec10 error:0 in libz.so.1.2.3.4[7f3482db7000+17000]
> >>>> [  197.330615]  in pigz[400000+10000]
> >>>>
> >>>> With 3.8 it is the same as with 3.8.4 or 3.8.5.
> >>>>
> >>>
> >>> Ok. Are there NUMA machines were you do *not* see this problem?
> >> Sadly no.
> >>
> >> I can really fast reproduce it with this one:
> >> 1.) Machine with only 16GB Mem
> >> 2.) compressing two 60GB Files in parallel with pigz consuming all cores
> >>
> > 
> > Ok, I'm dealing with this slower than I'd like due to an unfortunate
> > abundance of bugs right now. I am putting together a reproduction case but
> > I still can't trigger it unfortunately. Can you post your .config in case
> > it's my kernel config that is the reason I can't see the problem please?
> 
> no problem. Attaches is my kernel config.
> 

It does indeed appear that the kernel configuration is a factor.  Can you
try applying the following to your .config please?

--- config-bad  2013-04-07 21:08:02.213112445 +0100
+++ .config     2013-04-07 23:28:09.275973625 +0100
@@ -2518,8 +2518,8 @@
 CONFIG_TMPFS=y
 CONFIG_TMPFS_POSIX_ACL=y
 CONFIG_TMPFS_XATTR=y
-# CONFIG_HUGETLBFS is not set
-# CONFIG_HUGETLB_PAGE is not set
+CONFIG_HUGETLBFS=y
+CONFIG_HUGETLB_PAGE=y
 CONFIG_CONFIGFS_FS=y
 CONFIG_MISC_FILESYSTEMS=y
 # CONFIG_ADFS_FS is not set

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
