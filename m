Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id JAA01585
	for <linux-mm@kvack.org>; Thu, 26 Sep 2002 09:44:26 -0700 (PDT)
Message-ID: <3D933964.91C114F4@digeo.com>
Date: Thu, 26 Sep 2002 09:44:20 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] 2.5.38-mm3 : use struct file to call generic_file_direct_IO
References: <OFA4BB5A35.3807A0D1-ON88256C40.00593B2F@boulder.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <badari@us.ibm.com>
Cc: Chuck Lever <cel@citi.umich.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Badari Pulavarty wrote:
> 
> Hi Andrew & Chuck,
> 
> This patch looks good. As we discussed earlier, this breaks "raw" driver.

Yes, Chuck's patch is clearly the right thing to do.  I got caught
out cheating :(

The problem was caused by the consolidation of the raw driver - it 
does not have a file * for the target blockdev inode.

> I can fix it. Please let me know, if you want me to work on it.
> 

OK, thanks.  I guess we can either:

- Just create a temp struct file on the stack (bit risky)

- Change the raw device's userspace API and make raw bind to
  fd's, not majors/minors

- Change rw_raw_dev to call inode->i_mapping->aops->direct_IO
  directly.

The latter sounds suitable ;)  I should have done that on
day one.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
