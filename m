Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 04B856B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 21:34:26 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so59919747pdb.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 18:34:25 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ag9si39390433pad.217.2015.03.18.18.34.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 18:34:24 -0700 (PDT)
Message-ID: <550A2797.3000708@oracle.com>
Date: Wed, 18 Mar 2015 18:34:15 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 3/4] hugetlbfs: accept subpool min_size mount option
 and setup accordingly
References: <cover.1426549010.git.mike.kravetz@oracle.com>	<cfcd697cffc0f3500ecdb3371350a2613ee22f2e.1426549011.git.mike.kravetz@oracle.com> <20150318144054.c099e8a5e462303eea707252@linux-foundation.org>
In-Reply-To: <20150318144054.c099e8a5e462303eea707252@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 03/18/2015 02:40 PM, Andrew Morton wrote:
> On Mon, 16 Mar 2015 16:53:28 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
>
>> Make 'min_size=' be an option when mounting a hugetlbfs.  This option
>> takes the same value as the 'size' option.  min_size can be specified
>> with specifying size.  If both are specified, min_size must be less
>> that or equal to size else the mount will fail.  If min_size is
>> specified, then at mount time an attempt is made to reserve min_size
>> pages.  If the reservation fails, the mount fails.  At umount time,
>> the reserved pages are released.
>>
>> ...
>>
>> @@ -761,14 +763,32 @@ static const struct super_operations hugetlbfs_ops = {
>>   	.show_options	= generic_show_options,
>>   };
>>
>> +enum { NO_SIZE, SIZE_STD, SIZE_PERCENT };
>> +
>> +static bool
>> +hugetlbfs_options_setsize(struct hstate *h, long long *size, int setsize)
>> +{
>> +	if (setsize == NO_SIZE)
>> +		return false;
>> +
>> +	if (setsize == SIZE_PERCENT) {
>> +		*size <<= huge_page_shift(h);
>> +		*size *= h->max_huge_pages;
>> +		do_div(*size, 100);
>
> I suppose do_div() takes a long long.  u64 would be more conventional.
> I don't *think* all this code needed to use signed types.
>
>> +	}
>> +
>> +	*size >>= huge_page_shift(h);
>> +	return true;
>> +}
>> +
>>   static int
>>   hugetlbfs_parse_options(char *options, struct hugetlbfs_config *pconfig)
>>   {
>>   	char *p, *rest;
>>   	substring_t args[MAX_OPT_ARGS];
>>   	int option;
>> -	unsigned long long size = 0;
>> -	enum { NO_SIZE, SIZE_STD, SIZE_PERCENT } setsize = NO_SIZE;
>> +	unsigned long long max_size = 0, min_size = 0;
>> +	int max_setsize = NO_SIZE, min_setsize = NO_SIZE;
>>
>>   	if (!options)
>>   		return 0;
>> @@ -806,10 +826,10 @@ hugetlbfs_parse_options(char *options, struct hugetlbfs_config *pconfig)
>>   			/* memparse() will accept a K/M/G without a digit */
>>   			if (!isdigit(*args[0].from))
>>   				goto bad_val;
>> -			size = memparse(args[0].from, &rest);
>> -			setsize = SIZE_STD;
>> +			max_size = memparse(args[0].from, &rest);
>> +			max_setsize = SIZE_STD;
>>   			if (*rest == '%')
>> -				setsize = SIZE_PERCENT;
>> +				max_setsize = SIZE_PERCENT;
>>   			break;
>>   		}
>>
>> @@ -832,6 +852,17 @@ hugetlbfs_parse_options(char *options, struct hugetlbfs_config *pconfig)
>>   			break;
>>   		}
>>
>> +		case Opt_min_size: {
>> +			/* memparse() will accept a K/M/G without a digit */
>> +			if (!isdigit(*args[0].from))
>> +				goto bad_val;
>> +			min_size = memparse(args[0].from, &rest);
>> +			min_setsize = SIZE_STD;
>> +			if (*rest == '%')
>> +				min_setsize = SIZE_PERCENT;
>> +			break;
>> +		}
>> +
>>   		default:
>>   			pr_err("Bad mount option: \"%s\"\n", p);
>>   			return -EINVAL;
>> @@ -839,15 +870,17 @@ hugetlbfs_parse_options(char *options, struct hugetlbfs_config *pconfig)
>>   		}
>>   	}
>>
>> -	/* Do size after hstate is set up */
>> -	if (setsize > NO_SIZE) {
>> -		struct hstate *h = pconfig->hstate;
>> -		if (setsize == SIZE_PERCENT) {
>> -			size <<= huge_page_shift(h);
>> -			size *= h->max_huge_pages;
>> -			do_div(size, 100);
>> -		}
>> -		pconfig->nr_blocks = (size >> huge_page_shift(h));
>> +	/* Calculate number of huge pages based on hstate */
>> +	if (hugetlbfs_options_setsize(pconfig->hstate, &max_size, max_setsize))
>> +		pconfig->nr_blocks = max_size;
>
> So hugetlbfs_options_setsize takes an arg whichis in units of bytes,
> modifies it in-place to b in units of pages and then copies it into
> something which is in units of nr_blocks.
>
>
>> +	if (hugetlbfs_options_setsize(pconfig->hstate, &min_size, min_setsize))
>> +		pconfig->min_size = min_size;
>> +
>> +	/* If max_size specified, then min_size must be smaller */
>> +	if (max_setsize > NO_SIZE && min_setsize > NO_SIZE &&
>> +	    pconfig->min_size > pconfig->nr_blocks) {
>> +		pr_err("minimum size can not be greater than maximum size\n");
>> +		return -EINVAL;
>>   	}
>>
>>   	return 0;
>> @@ -872,6 +905,7 @@ hugetlbfs_fill_super(struct super_block *sb, void *data, int silent)
>>   	config.gid = current_fsgid();
>>   	config.mode = 0755;
>>   	config.hstate = &default_hstate;
>> +	config.min_size = 0; /* No default minimum size */
>>   	ret = hugetlbfs_parse_options(data, &config);
>>   	if (ret)
>>   		return ret;
>> @@ -885,8 +919,15 @@ hugetlbfs_fill_super(struct super_block *sb, void *data, int silent)
>>   	sbinfo->max_inodes = config.nr_inodes;
>>   	sbinfo->free_inodes = config.nr_inodes;
>>   	sbinfo->spool = NULL;
>> -	if (config.nr_blocks != -1) {
>> -		sbinfo->spool = hugepage_new_subpool(config.nr_blocks);
>> +	/*
>> +	 * Allocate and initialize subpool if maximum or minimum size is
>> +	 * specified.  Any needed reservations (for minimim size) are taken
>> +	 * taken when the subpool is created.
>> +	 */
>> +	if (config.nr_blocks != -1 || config.min_size != 0) {
>> +		sbinfo->spool = hugepage_new_subpool(config.hstate,
>> +							config.nr_blocks,
>> +							config.min_size);
>
> And hugepage_new_subpool() takes something in units of nr_blocks and
> copies it into something whcih has units of nr-hugepages.
>
> And it takes an arg called "size" which is no longer number-of-bytes
> but is actually number-of-hpages.
>
>
> It's all rather confusing and unclear.  A good philosophy would be
> never to use a variable called "size", because the reader doesn't know
> what units that size is measured in.  Instead, make sure that the name
> reflects the variable's units.  max_bytes, min_hpages, nr_blocks, etc.
>

Thanks for the comments.

I didn't want to cut/paste/duplicate the code used to parse the existing
size option.  But, it looks like I made it harder to understand.  I'll
take a pass as cleaning this up and making it more clear.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
