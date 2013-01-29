Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id E96BE6B000E
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 15:49:23 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 29 Jan 2013 15:49:22 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 97D4CC90044
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 15:49:18 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0TKnIXi20512906
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 15:49:18 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0TKnFMG024930
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 18:49:16 -0200
Message-ID: <510835C6.8070200@linux.vnet.ibm.com>
Date: Tue, 29 Jan 2013 14:49:10 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv3 1/6] debugfs: add get/set for atomic types
References: <1359409767-30092-1-git-send-email-sjenning@linux.vnet.ibm.com> <1359409767-30092-2-git-send-email-sjenning@linux.vnet.ibm.com> <20130129203509.GB27740@konrad-lan.dumpdata.com>
In-Reply-To: <20130129203509.GB27740@konrad-lan.dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/29/2013 02:35 PM, Konrad Rzeszutek Wilk wrote:
> On Mon, Jan 28, 2013 at 03:49:22PM -0600, Seth Jennings wrote:
>> debugfs currently lack the ability to create attributes
>> that set/get atomic_t values.
>>
>> This patch adds support for this through a new
>> debugfs_create_atomic_t() function.
>>
>> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
>> Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> ---
>>  fs/debugfs/file.c       |   42 ++++++++++++++++++++++++++++++++++++++++++
>>  include/linux/debugfs.h |    2 ++
>>  2 files changed, 44 insertions(+)
>>
>> diff --git a/fs/debugfs/file.c b/fs/debugfs/file.c
>> index c5ca6ae..fa26d5b 100644
>> --- a/fs/debugfs/file.c
>> +++ b/fs/debugfs/file.c
>> @@ -21,6 +21,7 @@
>>  #include <linux/debugfs.h>
>>  #include <linux/io.h>
>>  #include <linux/slab.h>
>> +#include <linux/atomic.h>
>>  
>>  static ssize_t default_read_file(struct file *file, char __user *buf,
>>  				 size_t count, loff_t *ppos)
>> @@ -403,6 +404,47 @@ struct dentry *debugfs_create_size_t(const char *name, umode_t mode,
>>  }
>>  EXPORT_SYMBOL_GPL(debugfs_create_size_t);
>>  
>> +static int debugfs_atomic_t_set(void *data, u64 val)
> 
> Should the 'data' be 'atomic_t *' just to make sure nobody messes this
> up? Or would that bring too much header changes?

DEFINE_SIMPLE_ATTRIBUTE() uses simple_attr_open() whose signature
requires the argument be a void *.  So we can't change it (easily).

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
