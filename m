Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 1E5766B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 05:16:03 -0400 (EDT)
Received: by obbta14 with SMTP id ta14so2911800obb.14
        for <linux-mm@kvack.org>; Fri, 23 Mar 2012 02:16:02 -0700 (PDT)
Message-ID: <4F6C3F29.8090402@gmail.com>
Date: Fri, 23 Mar 2012 17:15:21 +0800
From: bill4carson <bill4carson@gmail.com>
MIME-Version: 1.0
Subject: Re: Why memory.usage_in_bytes is always increasing after every mmap/dirty/unmap
 sequence
References: <4F6C2E9B.9010200@gmail.com> <4F6C31F7.2010804@jp.fujitsu.com> <4F6C3B7F.1070705@gmail.com> <4F6C3C88.5090800@jp.fujitsu.com>
In-Reply-To: <4F6C3C88.5090800@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>



On 2012a1'03ae??23ae?JPY 17:04, KAMEZAWA Hiroyuki wrote:
> (2012/03/23 17:59), bill4carson wrote:
>
>>
>>
>> On 2012a1'03ae??23ae?JPY 16:19, KAMEZAWA Hiroyuki wrote:
>>> (2012/03/23 17:04), bill4carson wrote:
>>>
>>>> Hi, all
>>>>
>>>> I'm playing with memory cgroup, I'm a bit confused why
>>>> memory.usage in bytes is steadily increasing at 4K page pace
>>>> after every mmap/dirty/unmap sequence.
>>>>
>>>> On linux-3.6.34.10/linux-3.3.0-rc5
>>>> A simple test case does following:
>>>>
>>>> a) mmap 128k memory in private anonymous way
>>>> b) dirty all 128k to demand physical page
>>>> c) print memory.usage_in_bytes<-- increased at 4K after every loop
>>>> d) unmap previous 128 memory
>>>> e) goto a) to repeat
>>>
>>> In Documentation/cgroup/memory.txt
>>> ==
>>> 5.5 usage_in_bytes
>>>
>>> For efficiency, as other kernel components, memory cgroup uses some optimization
>>> to avoid unnecessary cacheline false sharing. usage_in_bytes is affected by the
>>> method and doesn't show 'exact' value of memory(and swap) usage, it's an fuzz
>>> value for efficient access. (Of course, when necessary, it's synchronized.)
>>> If you want to know more exact memory usage, you should use RSS+CACHE(+SWAP)
>>> value in memory.stat(see 5.2).
>>> ==
>>>
>>> In current implementation, memcg tries to charge resource in size of 32 pages.
>>> So, if you get 32 pages and free 32pages, usage_in_bytes may not change.
>>> This is affected by caches in other cpus and other flushing operations caused
>>> by some workload in other cgroups. memcg's usage_in_bytes is not precise in
>>> 128k degree.
>>>
>> Yes, I tried to mmap/dirty/unmap in 32 times, when the usage_in_bytes
>> reached 128k, it rolls back to 4k again. So it doesn't hurt any more.
>
>
> rolls back before unmap() ?
>
After unmap

>>
>> I haven't found the code regarding to this behavior.
>
>
> Could you post your test program ?
>
Yes, it's a bit of messy, you can mock at me:)

-------------------------------------------------------------
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/eventfd.h>
#include <fcntl.h>
#include <limits.h>

#define MMAP_SIZE (128*1024)

int * ptr_array[1024];
int depth=0;

char cmd;
int pagesize;
int mapsize;

void get_key(void)
{

	cmd = getchar();
	putchar('\n');
	getchar();
}

int is_this_key(char key)
{
	return (cmd == key) ? 1:0;
}

void getpage(int *ptr)
{
	int i;
	for (i = 0; i < mapsize/4098; i++){
		*ptr = 4;/* alloc a physical page */
		ptr += 1024; /*move to next page*/
	}
}
void show_stat(void)
{
	int i;

	for (i = depth; i--; i < 0){
		printf("[%2d]:%8p\n", i, ptr_array[i]);
	}

}
int main(int argc, char ** argv)
{

	int *ptr;
	int i;
     char usage_in_bytes_path[PATH_MAX];
	char          tasks_path[PATH_MAX];
     char                 tmp[PATH_MAX];
     int usage_in_bytes = -1;
	int fd_tasks = -1;

	char *root_path;
	int ret;

	if (argc > 2)
		printf("Usage: oomtst [map size]\n");

	mapsize = MMAP_SIZE;


	strcpy(tmp, argv[1]);
	root_path = dirname(tmp);
	printf("root_path:%s\n", root_path);

	ret = snprintf(usage_in_bytes_path, PATH_MAX, 
"%s/memory.usage_in_bytes", root_path);
	if (ret >= PATH_MAX) {
		fputs("Path to memory.usage_in_bytes is too long\n", stderr);
		goto out;
	}
	puts(usage_in_bytes_path);

	ret = snprintf(tasks_path, PATH_MAX, "%s/tasks", root_path);
	if (ret >= PATH_MAX) {
		fputs("Path to memory.usage_in_bytes is too long\n", stderr);
		goto out;
	}
	puts(tasks_path);
	
	fd_tasks = open(tasks_path, O_WRONLY);
	if (fd_tasks == -1) {
		fprintf(stderr, "Cannot open %s: %s\n", tasks_path,
				strerror(errno));
		goto out;
	}

	printf("Using PID:%u\n", getpid());
	{
		char tasks_str[32];

		ret = sprintf(tasks_str, "%d", getpid());
		ret = write(fd_tasks, tasks_str, strlen(tasks_str));

	}


	while(1){
		char used_bytes[64];
		uint64_t tmp;

		usage_in_bytes = open(usage_in_bytes_path, O_RDWR);
		if (usage_in_bytes == -1) {
			fprintf(stderr, "Cannot open %s: %s\n", usage_in_bytes_path,
				strerror(errno));
			goto out;
		}



		printf("Enter a command (m: malloc f: free ?: exit):");
		get_key();

		if (is_this_key('m')) {	
			ptr_array[depth] = mmap(NULL, mapsize, PROT_READ | PROT_WRITE, 
MAP_PRIVATE|MAP_ANON, 0, 0);
			if (ptr_array[depth] == NULL){
				perror("msg: cannot malloc\n");
				exit(2);
			}

			printf("malloc %d Kbytes at %p\n", mapsize/1024, ptr_array[depth]);
			getpage(ptr_array[depth]);
			depth++;

		}else if (is_this_key('f')) {
			if (depth == 0)
				break;

			printf("free %d Kbytes at %p\n", mapsize/1024, ptr_array[depth -1]);
			munmap(ptr_array[depth -1], mapsize);
			--depth;

		}else
			break;

		show_stat();


		memset(&used_bytes, 0, 33/*sizeof(used_bytes)*/);
		ret = read(usage_in_bytes, &used_bytes, 32);
		if (ret == -1) {
			perror("Cannot read from usage_in_bytes");
			break;
		}
		tmp = atoll(used_bytes);
         printf("used_bytes:%llu Kbytes\n", tmp/1024);

		if (usage_in_bytes >= 0)
			close(usage_in_bytes);

	}
	
	out:
		for (i = 0; i < depth; i++){
			printf("free %d Kbytes at %p\n", mapsize/1024, ptr_array[i]);
			munmap(ptr_array[i], mapsize);
		}


	if (usage_in_bytes >= 0)
		close(usage_in_bytes);

	return 0;
}



> Thanks,
> -Kame
>
>

-- 
Love each day!

--bill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
