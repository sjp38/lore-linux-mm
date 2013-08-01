Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id B87A36B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 17:58:59 -0400 (EDT)
Message-ID: <1375394271.10300.18.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 02/18] earlycpio.c: Fix the confusing comment of
 find_cpio_data().
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 01 Aug 2013 15:57:51 -0600
In-Reply-To: <1375340800-19332-3-git-send-email-tangchen@cn.fujitsu.com>
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>
	 <1375340800-19332-3-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Thu, 2013-08-01 at 15:06 +0800, Tang Chen wrote:
> The comments of find_cpio_data() says:
> 
>   * @offset: When a matching file is found, this is the offset to the
>   *          beginning of the cpio. ......
> 
> But according to the code,
> 
>   dptr = PTR_ALIGN(p + ch[C_NAMESIZE], 4);
>   nptr = PTR_ALIGN(dptr + ch[C_FILESIZE], 4);
>   ....
>   *offset = (long)nptr - (long)data;	/* data is the cpio file */
> 
> @offset is the offset of the next file, not the matching file itself.
> This is confused and may cause unnecessary waste of time to debug.
> So fix it.
> 
> v1 -> v2:
> As tj suggested, rename @offset to @nextoff which is more clear to
> users. And also adjust the new comments.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> ---
>  lib/earlycpio.c |   27 ++++++++++++++-------------
>  1 files changed, 14 insertions(+), 13 deletions(-)
> 
> diff --git a/lib/earlycpio.c b/lib/earlycpio.c
> index 8078ef4..7affac0 100644
> --- a/lib/earlycpio.c
> +++ b/lib/earlycpio.c
> @@ -49,22 +49,23 @@ enum cpio_fields {
>  
>  /**
>   * cpio_data find_cpio_data - Search for files in an uncompressed cpio
> - * @path:   The directory to search for, including a slash at the end
> - * @data:   Pointer to the the cpio archive or a header inside
> - * @len:    Remaining length of the cpio based on data pointer
> - * @offset: When a matching file is found, this is the offset to the
> - *          beginning of the cpio. It can be used to iterate through
> - *          the cpio to find all files inside of a directory path
> + * @path:       The directory to search for, including a slash at the end
> + * @data:       Pointer to the the cpio archive or a header inside
> + * @len:        Remaining length of the cpio based on data pointer
> + * @nextoff:    When a matching file is found, this is the offset from the
> + *              beginning of the cpio to the beginning of the next file, not the
> + *              matching file itself. It can be used to iterate through the cpio
> + *              to find all files inside of a directory path
>   *
> - * @return: struct cpio_data containing the address, length and
> - *          filename (with the directory path cut off) of the found file.
> - *          If you search for a filename and not for files in a directory,
> - *          pass the absolute path of the filename in the cpio and make sure
> - *          the match returned an empty filename string.
> + * @return:     struct cpio_data containing the address, length and
> + *              filename (with the directory path cut off) of the found file.
> + *              If you search for a filename and not for files in a directory,
> + *              pass the absolute path of the filename in the cpio and make sure
> + *              the match returned an empty filename string.
>   */
>  
>  struct cpio_data __cpuinit find_cpio_data(const char *path, void *data,

This patch does not apply cleanly.  It seems that your branch does not
have 0db0628d90125193280eabb501c94feaf48fa9ab.

Thanks,
-Toshi


> -					  size_t len,  long *offset)
> +					  size_t len,  long *nextoff)
>  {
>  	const size_t cpio_header_len = 8*C_NFIELDS - 2;
>  	struct cpio_data cd = { NULL, 0, "" };
> @@ -124,7 +125,7 @@ struct cpio_data __cpuinit find_cpio_data(const char *path, void *data,
>  		if ((ch[C_MODE] & 0170000) == 0100000 &&
>  		    ch[C_NAMESIZE] >= mypathsize &&
>  		    !memcmp(p, path, mypathsize)) {
> -			*offset = (long)nptr - (long)data;
> +			*nextoff = (long)nptr - (long)data;
>  			if (ch[C_NAMESIZE] - mypathsize >= MAX_CPIO_FILE_NAME) {
>  				pr_warn(
>  				"File %s exceeding MAX_CPIO_FILE_NAME [%d]\n",


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
