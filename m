Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FFFC6B0038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 17:04:04 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id n204so39475641oif.6
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 14:04:04 -0800 (PST)
Received: from da1vs02.rockwellcollins.com (da1vs02.rockwellcollins.com. [205.175.227.29])
        by mx.google.com with ESMTPS id s185si33485262oia.235.2017.01.05.14.04.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 14:04:03 -0800 (PST)
From: David Graziano <david.graziano@rockwellcollins.com>
Subject: [PATCH v4 0/3] initxattr callback update for mqueue xattr support
Date: Thu,  5 Jan 2017 16:03:40 -0600
Message-Id: <1483653823-22018-1-git-send-email-david.graziano@rockwellcollins.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-security-module@vger.kernel.org, paul@paul-moore.com
Cc: agruenba@redhat.com, hch@infradead.org, linux-mm@kvack.org, sds@tycho.nsa.gov, linux-kernel@vger.kernel.org, David Graziano <david.graziano@rockwellcollins.com>

This patchset is for implementing extended attribute support within the 
POSIX message queue (mqueue) file system. This is needed so that the 
security.selinux extended attribute can be set via a SELinux named type 
transition on file inodes created within the filesystem. I needed to 
write a selinux policy for a set of custom applications that use mqueues 
for their IPC. The mqueues are created by one application and we needed 
a way for selinux to enforce which of the other application are able to 
read/write to each individual queue. Uniquely labelling them based on the 
application that created them and the filename seemed to be our best 
solution as ita??s an embedded system and we dona??t have restorecond to 
handle any relabeling.

This series is a result of feedback from the v2 mqueue patch 
( http://marc.info/?l=linux-kernel&m=147855351826081&w=2 ) which 
duplicated the shmem_initxattrs() function for the mqueue file system. 
This patcheset creates a common simple_xattr_initxattrs() function that 
can be used by multiple virtual file systems to handle extended attribute 
initialization via LSM callback. simple_xattr_initxattrs() is an updated 
version of shmem_initxattrs(). As part of the this series both shmem and 
mqueue are updated to use the new common initxattrs function. 

Changes v3 -> v4:
 - fix uninitialized variable in mqueue patch (3/3)

Changes v2 -> v3:
 - creates new simple_xattr_initxattrs() function
 - updates shmem to use new callback function
 - updates mqueue to use new callback function

Changes v1 -> v2:
 - formatting/commit message


David Graziano (3):
  xattr: add simple initxattrs function
  shmem: use simple initxattrs callback
  mqueue: Implement generic xattr support

 fs/xattr.c            | 39 +++++++++++++++++++++++++++++++++++++
 include/linux/xattr.h |  3 +++
 ipc/mqueue.c          | 16 ++++++++++++++++
 mm/shmem.c            | 53 ++++++++++++---------------------------------------
 4 files changed, 70 insertions(+), 41 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
