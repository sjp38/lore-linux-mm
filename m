Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 882576B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 20:30:21 -0500 (EST)
Message-ID: <4F307F2F.4010400@redhat.com>
Date: Tue, 07 Feb 2012 09:32:31 +0800
From: Dave Young <dyoung@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] move hugepage test examples to tools/testing/selftests/vm
References: <20120205081555.GA2249@darkstar.redhat.com>
In-Reply-To: <20120205081555.GA2249@darkstar.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, xiyou.wangcong@gmail.com, penberg@kernel.org, fengguang.wu@intel.com, cl@linux.com

On 02/05/2012 04:15 PM, Dave Young wrote:

> hugepage-mmap.c, hugepage-shm.c and map_hugetlb.c in Documentation/vm are
> simple pass/fail tests, It's better to promote them to tools/testing/selftests
> 
> Thanks suggestion of Andrew Morton about this. They all need firstly setting up
> proper nr_hugepages and hugepage-mmap need to mount hugetlbfs. So I add a shell
> script run_test to do such work which will call the three test programs and
> check the return value of them.
> 
> Changes to original code including below:
> a. add run_test script
> b. return error when read_bytes mismatch with writed bytes.
> c. coding style fixes: do not use assignment in if condition
> 
> Signed-off-by: Dave Young <dyoung@redhat.com>
> ---
>  Documentation/vm/Makefile                          |    8 --
>  tools/testing/selftests/Makefile                   |    2 +-
>  tools/testing/selftests/run_tests                  |    6 +-
>  tools/testing/selftests/vm/Makefile                |   11 +++
>  .../testing/selftests}/vm/hugepage-mmap.c          |   13 ++--
>  .../testing/selftests}/vm/hugepage-shm.c           |   10 ++-
>  .../testing/selftests}/vm/map_hugetlb.c            |   10 ++-
>  tools/testing/selftests/vm/run_test                |   77 ++++++++++++++++++++
>  8 files changed, 112 insertions(+), 25 deletions(-)
>  delete mode 100644 Documentation/vm/Makefile
>  create mode 100644 tools/testing/selftests/vm/Makefile
>  rename {Documentation => tools/testing/selftests}/vm/hugepage-mmap.c (93%)
>  rename {Documentation => tools/testing/selftests}/vm/hugepage-shm.c (94%)
>  rename {Documentation => tools/testing/selftests}/vm/map_hugetlb.c (94%)
>  create mode 100755 tools/testing/selftests/vm/run_test
> 
> diff --git a/Documentation/vm/Makefile b/Documentation/vm/Makefile
> deleted file mode 100644
> index e538864..0000000
> --- a/Documentation/vm/Makefile
> +++ /dev/null
> @@ -1,8 +0,0 @@
> -# kbuild trick to avoid linker error. Can be omitted if a module is built.
> -obj- := dummy.o
> -
> -# List of programs to build
> -hostprogs-y := hugepage-mmap hugepage-shm map_hugetlb
> -
> -# Tell kbuild to always build the programs
> -always := $(hostprogs-y)
> diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
> index 4ec8401..9a72fe5 100644
> --- a/tools/testing/selftests/Makefile
> +++ b/tools/testing/selftests/Makefile
> @@ -1,4 +1,4 @@
> -TARGETS = breakpoints
> +TARGETS = breakpoints vm
>  
>  all:
>  	for TARGET in $(TARGETS); do \
> diff --git a/tools/testing/selftests/run_tests b/tools/testing/selftests/run_tests
> index 320718a..1f4a5ef 100644
> --- a/tools/testing/selftests/run_tests
> +++ b/tools/testing/selftests/run_tests
> @@ -1,8 +1,10 @@
>  #!/bin/bash
>  
> -TARGETS=breakpoints
> +TARGETS="breakpoints vm"
>  
>  for TARGET in $TARGETS
>  do
> -	$TARGET/run_test
> +	cd "$TARGET"
> +	./run_test
> +	cd ..
>  done
> diff --git a/tools/testing/selftests/vm/Makefile b/tools/testing/selftests/vm/Makefile
> new file mode 100644
> index 0000000..537ec38
> --- /dev/null
> +++ b/tools/testing/selftests/vm/Makefile
> @@ -0,0 +1,11 @@
> +# Makefile for vm selftests
> +
> +CC = $(CROSS_COMPILE)gcc
> +CFLAGS = -Wall -Wextra
> +
> +all: hugepage-mmap hugepage-shm  map_hugetlb
> +%: %.c
> +	$(CC) $(CFLAGS) -o $@ $^
> +
> +clean:
> +	$(RM) hugepage-mmap hugepage-shm  map_hugetlb
> diff --git a/Documentation/vm/hugepage-mmap.c b/tools/testing/selftests/vm/hugepage-mmap.c
> similarity index 93%
> rename from Documentation/vm/hugepage-mmap.c
> rename to tools/testing/selftests/vm/hugepage-mmap.c
> index db0dd9a..a10f310 100644
> --- a/Documentation/vm/hugepage-mmap.c
> +++ b/tools/testing/selftests/vm/hugepage-mmap.c
> @@ -22,7 +22,7 @@
>  #include <sys/mman.h>
>  #include <fcntl.h>
>  
> -#define FILE_NAME "/mnt/hugepagefile"
> +#define FILE_NAME "huge/hugepagefile"
>  #define LENGTH (256UL*1024*1024)
>  #define PROTECTION (PROT_READ | PROT_WRITE)
>  
> @@ -48,7 +48,7 @@ static void write_bytes(char *addr)
>  		*(addr + i) = (char)i;
>  }
>  
> -static void read_bytes(char *addr)
> +static int read_bytes(char *addr)
>  {
>  	unsigned long i;
>  
> @@ -56,14 +56,15 @@ static void read_bytes(char *addr)
>  	for (i = 0; i < LENGTH; i++)
>  		if (*(addr + i) != (char)i) {
>  			printf("Mismatch at %lu\n", i);
> -			break;
> +			return 1;
>  		}
> +	return 0;
>  }
>  
>  int main(void)
>  {
>  	void *addr;
> -	int fd;
> +	int fd, ret;
>  
>  	fd = open(FILE_NAME, O_CREAT | O_RDWR, 0755);
>  	if (fd < 0) {
> @@ -81,11 +82,11 @@ int main(void)
>  	printf("Returned address is %p\n", addr);
>  	check_bytes(addr);
>  	write_bytes(addr);
> -	read_bytes(addr);
> +	ret = read_bytes(addr);
>  
>  	munmap(addr, LENGTH);
>  	close(fd);
>  	unlink(FILE_NAME);
>  
> -	return 0;
> +	return ret;
>  }
> diff --git a/Documentation/vm/hugepage-shm.c b/tools/testing/selftests/vm/hugepage-shm.c
> similarity index 94%
> rename from Documentation/vm/hugepage-shm.c
> rename to tools/testing/selftests/vm/hugepage-shm.c
> index 07956d8..0d0ef4f 100644
> --- a/Documentation/vm/hugepage-shm.c
> +++ b/tools/testing/selftests/vm/hugepage-shm.c
> @@ -57,8 +57,8 @@ int main(void)
>  	unsigned long i;
>  	char *shmaddr;
>  
> -	if ((shmid = shmget(2, LENGTH,
> -			    SHM_HUGETLB | IPC_CREAT | SHM_R | SHM_W)) < 0) {
> +	shmid = shmget(2, LENGTH, SHM_HUGETLB | IPC_CREAT | SHM_R | SHM_W);
> +	if (shmid < 0) {
>  		perror("shmget");
>  		exit(1);
>  	}
> @@ -82,14 +82,16 @@ int main(void)
>  
>  	dprintf("Starting the Check...");
>  	for (i = 0; i < LENGTH; i++)
> -		if (shmaddr[i] != (char)i)
> +		if (shmaddr[i] != (char)i) {
>  			printf("\nIndex %lu mismatched\n", i);
> +			exit(3);
> +		}
>  	dprintf("Done.\n");
>  
>  	if (shmdt((const void *)shmaddr) != 0) {
>  		perror("Detach failure");
>  		shmctl(shmid, IPC_RMID, NULL);
> -		exit(3);
> +		exit(4);
>  	}
>  
>  	shmctl(shmid, IPC_RMID, NULL);
> diff --git a/Documentation/vm/map_hugetlb.c b/tools/testing/selftests/vm/map_hugetlb.c
> similarity index 94%
> rename from Documentation/vm/map_hugetlb.c
> rename to tools/testing/selftests/vm/map_hugetlb.c
> index eda1a6d..ac56639 100644
> --- a/Documentation/vm/map_hugetlb.c
> +++ b/tools/testing/selftests/vm/map_hugetlb.c
> @@ -44,7 +44,7 @@ static void write_bytes(char *addr)
>  		*(addr + i) = (char)i;
>  }
>  
> -static void read_bytes(char *addr)
> +static int read_bytes(char *addr)
>  {
>  	unsigned long i;
>  
> @@ -52,13 +52,15 @@ static void read_bytes(char *addr)
>  	for (i = 0; i < LENGTH; i++)
>  		if (*(addr + i) != (char)i) {
>  			printf("Mismatch at %lu\n", i);
> -			break;
> +			return 1;
>  		}
> +	return 0;
>  }
>  
>  int main(void)
>  {
>  	void *addr;
> +	int ret;
>  
>  	addr = mmap(ADDR, LENGTH, PROTECTION, FLAGS, 0, 0);
>  	if (addr == MAP_FAILED) {
> @@ -69,9 +71,9 @@ int main(void)
>  	printf("Returned address is %p\n", addr);
>  	check_bytes(addr);
>  	write_bytes(addr);
> -	read_bytes(addr);
> +	ret = read_bytes(addr);
>  
>  	munmap(addr, LENGTH);
>  
> -	return 0;
> +	return ret;
>  }
> diff --git a/tools/testing/selftests/vm/run_test b/tools/testing/selftests/vm/run_test
> new file mode 100755
> index 0000000..33d355d
> --- /dev/null
> +++ b/tools/testing/selftests/vm/run_test
> @@ -0,0 +1,77 @@
> +#!/bin/bash
> +#please run as root
> +
> +#we need 256M, below is the size in kB
> +needmem=262144
> +mnt=./huge
> +
> +#get pagesize and freepages from /proc/meminfo
> +while read name size unit; do
> +	if [ "$name" = "HugePages_Free:" ]; then
> +		freepgs=$size
> +	fi
> +	if [ "$name" = "Hugepagesize:" ]; then
> +		pgsize=$size
> +	fi
> +done < /proc/meminfo
> +
> +#set proper nr_hugepages
> +if [ -n "$freepgs" ] && [ -n "$pgsize" ]; then
> +	nr_hugepgs=`cat /proc/sys/vm/nr_hugepages`
> +	needpgs=`expr $needmem / $pgsize`
> +	if [ $freepgs -lt $needpgs ]; then
> +		lackpgs=$(( $needpgs - $freepgs ))
> +		echo $(( $lackpgs + $nr_hugepgs )) > /proc/sys/vm/nr_hugepages
> +		if [ $? -ne 0 ]; then
> +			echo "Please run this test as root"
> +			exit 1
> +		fi
> +	fi
> +else
> +	echo "no hugetlbfs support in kernel?"
> +	exit 1
> +fi
> +
> +mkdir $mnt
> +mount -t hugetlbfs none $mnt
> +
> +echo "--------------------"
> +echo "runing hugepage-mmap"
> +echo "--------------------"
> +./hugepage-mmap
> +if [ $? -ne 0 ]; then
> +	echo "[FAIL]"
> +else
> +	echo "[PASS]"
> +fi
> +
> +shmmax=`cat /proc/sys/kernel/shmmax`
> +shmall=`cat /proc/sys/kernel/shmall`
> +echo 268435456 > /proc/sys/kernel/shmmax
> +echo 4194304 > /proc/sys/kernel/shmall
> +echo "--------------------"
> +echo "runing hugepage-shm"
> +echo "--------------------"
> +./hugepage-shm
> +echo $shmmax > /proc/sys/kernel/shmmax
> +echo $shmall > /proc/sys/kernel/shmall
> +if [ $? -ne 0 ]; then


Oops, $? check place is wrong, will fix in v2

> +	echo "[FAIL]"
> +else
> +	echo "[PASS]"
> +fi
> +
> +echo "--------------------"
> +echo "runing map_hugetlb"
> +echo "--------------------"
> +./map_hugetlb
> +if [ $? -ne 0 ]; then
> +	echo "[FAIL]"
> +else
> +	echo "[PASS]"
> +fi
> +
> +#cleanup
> +umount $mnt
> +rm -rf $mnt
> +echo $nr_hugepgs > /proc/sys/vm/nr_hugepages



-- 
Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
