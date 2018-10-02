Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BC41B6B0003
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 10:20:14 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id g36-v6so2491165plb.5
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 07:20:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e62-v6si17539949pfe.31.2018.10.02.07.20.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 07:20:13 -0700 (PDT)
Date: Tue, 2 Oct 2018 16:20:10 +0200
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181002142010.GB4963@linux-x5ow.site>
References: <20181002100531.GC4135@quack2.suse.cz>
 <20181002121039.GA3274@linux-x5ow.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181002121039.GA3274@linux-x5ow.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, mhocko@suse.cz, Dan Williams <dan.j.williams@intel.com>

On Tue, Oct 02, 2018 at 02:10:39PM +0200, Johannes Thumshirn wrote:
> On Tue, Oct 02, 2018 at 12:05:31PM +0200, Jan Kara wrote:
> > Hello,
> > 
> > commit e1fb4a086495 "dax: remove VM_MIXEDMAP for fsdax and device dax" has
> > removed VM_MIXEDMAP flag from DAX VMAs. Now our testing shows that in the
> > mean time certain customer of ours started poking into /proc/<pid>/smaps
> > and looks at VMA flags there and if VM_MIXEDMAP is missing among the VMA
> > flags, the application just fails to start complaining that DAX support is
> > missing in the kernel. The question now is how do we go about this?
> 
> OK naive question from me, how do we want an application to be able to
> check if it is running on a DAX mapping?
> 
> AFAIU DAX is always associated with a file descriptor of some kind (be
> it a real file with filesystem dax or the /dev/dax device file for
> device dax). So could a new fcntl() be of any help here? IS_DAX() only
> checks for the S_DAX flag in inode::i_flags, so this should be doable
> for both fsdax and devdax.
> 
> I haven't tried it yet but it should be fairly easy to come up with
> something like this.

OK now I did on a normal file on BTFS (without DAX obviously) and on a
file on XFS with the -o dax mount option.

Here's the RFC:

commit 3a8f0d23c421e8c91bc9d8bd3a956e1ffe3f754b
Author: Johannes Thumshirn <jthumshirn@suse.de>
Date:   Tue Oct 2 14:51:33 2018 +0200

    fcntl: provide F_GETDAX for applications to query DAX capabilities
    
    Provide a F_GETDAX fcntl(2) command so an application can query
    whether it can make use of DAX or not.
    
    Both file-system DAX as well as device DAX mark the DAX capability in
    struct inode::i_flags using the S_DAX flag, so we can query it using
    the IS_DAX() macro on a struct file's inode.
    
    If the file descriptor is either device DAX or on a DAX capable
    file-system '1' is returned back to user-space, if DAX isn't usable
    for some reason '0' is returned back.
    
    This patch can be tested with the following small C program:
    
     #include <stdio.h>
     #include <stdlib.h>
     #include <unistd.h>
     #include <fcntl.h>
     #include <libgen.h>
    
     #ifndef F_LINUX_SPECIFIC_BASE
     #define F_LINUX_SPECIFIC_BASE 1024
     #endif
    
     #define F_GETDAX               (F_LINUX_SPECIFIC_BASE + 15)
    
     int main(int argc, char **argv)
     {
            int dax;
            int fd;
            int rc;
    
            if (argc != 2) {
                    printf("Usage: %s file\n", basename(argv[0]));
                    exit(EXIT_FAILURE);
            }
    
            fd = open(argv[1], O_RDONLY);
            if (fd < 0) {
                    perror("open");
                    exit(EXIT_FAILURE);
            }
    
            rc = fcntl(fd, F_GETDAX, &dax);
            if (rc < 0) {
                    perror("fcntl");
                    close(fd);
                    exit(EXIT_FAILURE);
            }
    
            if (dax) {
                    printf("fd %d is dax capable\n", fd);
                    exit(EXIT_FAILURE);
            } else {
                    printf("fd %d is not dax capable\n", fd);
                    exit(EXIT_SUCCESS);
            }
     }
    
    Signed-off-by: Johannes Thumshirn <jthumshirn@suse.de>
    Cc: Jan Kara <jack@suse.cz>
    Cc: Michal Hocko <mhocko@suse.cz>
    Cc: Dan Williams <dan.j.williams@intel.com>

diff --git a/fs/fcntl.c b/fs/fcntl.c
index 4137d96534a6..0b53f968f569 100644
--- a/fs/fcntl.c
+++ b/fs/fcntl.c
@@ -32,6 +32,22 @@
 
 #define SETFL_MASK (O_APPEND | O_NONBLOCK | O_NDELAY | O_DIRECT | O_NOATIME)
 
+static int fcntl_get_dax(struct file *filp, unsigned long arg)
+{
+	struct inode *inode = file_inode(filp);
+	u64 *argp = (u64 __user *)arg;
+	u64 dax;
+
+	if (IS_DAX(inode))
+		dax = 1;
+	else
+		dax = 0;
+
+	if (copy_to_user(argp, &dax, sizeof(*argp)))
+		return -EFAULT;
+	return 0;
+}
+
 static int setfl(int fd, struct file * filp, unsigned long arg)
 {
 	struct inode * inode = file_inode(filp);
@@ -426,6 +442,9 @@ static long do_fcntl(int fd, unsigned int cmd, unsigned long arg,
 	case F_SET_FILE_RW_HINT:
 		err = fcntl_rw_hint(filp, cmd, arg);
 		break;
+	case F_GETDAX:
+		err = fcntl_get_dax(filp, arg);
+		break;
 	default:
 		break;
 	}
diff --git a/include/uapi/linux/fcntl.h b/include/uapi/linux/fcntl.h
index 6448cdd9a350..65a59c3cc46d 100644
--- a/include/uapi/linux/fcntl.h
+++ b/include/uapi/linux/fcntl.h
@@ -52,6 +52,7 @@
 #define F_SET_RW_HINT		(F_LINUX_SPECIFIC_BASE + 12)
 #define F_GET_FILE_RW_HINT	(F_LINUX_SPECIFIC_BASE + 13)
 #define F_SET_FILE_RW_HINT	(F_LINUX_SPECIFIC_BASE + 14)
+#define F_GETDAX		(F_LINUX_SPECIFIC_BASE + 15)
 
 /*
  * Valid hint values for F_{GET,SET}_RW_HINT. 0 is "not set", or can be


-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nurnberg
GF: Felix Imendorffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nurnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
