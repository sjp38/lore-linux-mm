Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 673DB6B00EA
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 12:09:15 -0500 (EST)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0KH08Sg000829
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 12:00:09 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 409284DE8041
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 12:05:47 -0500 (EST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0KH96uN425336
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 12:09:06 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0KH957K025633
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 10:09:05 -0700
Subject: Re: [PATCH 0/4] De-couple sysfs memory directories from memory
 sections
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110120164555.GA30922@kroah.com>
References: <4D386498.9080201@austin.ibm.com>
	 <20110120164555.GA30922@kroah.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Thu, 20 Jan 2011 09:09:01 -0800
Message-ID: <1295543341.9039.588.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: Nathan Fontenot <nfont@austin.ibm.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2011-01-20 at 08:45 -0800, Greg KH wrote:
> On Thu, Jan 20, 2011 at 10:36:40AM -0600, Nathan Fontenot wrote:
> > The root of this issue is in sysfs directory creation. Every time
> > a directory is created a string compare is done against sibling
> > directories ( see sysfs_find_dirent() ) to ensure we do not create 
> > duplicates.  The list of directory nodes in sysfs is kept as an
> > unsorted list which results in this being an exponentially longer
> > operation as the number of directories are created.
> 
> Again, are you sure about this?  I thought we resolved this issue in the
> past, but you were going to check it.  Did you?

Just to be clear, simply reducing the number of kobjects can make these
patches worthwhile on their own.  I originally figured that the
SECTION_SIZE would go up over time as systems got larger, and _that_
would keep the number of sections and number of sysfs objects down.
Well, that turned out to be wrong, and we're eating up a ton of memory
now.  We can't fix the SECTION_SIZE easily, but we can reduce the number
of kobjects that we need to track the sections.  *That* is the main
benefit I see from these patches.

I think there's a problem worth fixing, even ignoring the directory
creation issue (if it still exists).

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
