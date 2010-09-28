Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AD9B66B004A
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 08:44:55 -0400 (EDT)
Message-ID: <4CA1E338.6070201@redhat.com>
Date: Tue, 28 Sep 2010 14:44:40 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] v2 De-Couple sysfs memory directories from memory
 sections
References: <4CA0EBEB.1030204@austin.ibm.com>
In-Reply-To: <4CA0EBEB.1030204@austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

  On 09/27/2010 09:09 PM, Nathan Fontenot wrote:
> This set of patches decouples the concept that a single memory
> section corresponds to a single directory in
> /sys/devices/system/memory/.  On systems
> with large amounts of memory (1+ TB) there are perfomance issues
> related to creating the large number of sysfs directories.  For
> a powerpc machine with 1 TB of memory we are creating 63,000+
> directories.  This is resulting in boot times of around 45-50
> minutes for systems with 1 TB of memory and 8 hours for systems
> with 2 TB of memory.  With this patch set applied I am now seeing
> boot times of 5 minutes or less.
>
> The root of this issue is in sysfs directory creation. Every time
> a directory is created a string compare is done against all sibling
> directories to ensure we do not create duplicates.  The list of
> directory nodes in sysfs is kept as an unsorted list which results
> in this being an exponentially longer operation as the number of
> directories are created.
>
> The solution solved by this patch set is to allow a single
> directory in sysfs to span multiple memory sections.  This is
> controlled by an optional architecturally defined function
> memory_block_size_bytes().  The default definition of this
> routine returns a memory block size equal to the memory section
> size. This maintains the current layout of sysfs memory
> directories as it appears to userspace to remain the same as it
> is today.
>

Why not update sysfs directory creation to be fast, for example by using 
an rbtree instead of a linked list.  This fixes an implementation 
problem in the kernel instead of working around it and creating a new ABI.

New ABIs mean old tools won't work, and new tools need to understand 
both ABIs.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
