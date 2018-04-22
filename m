Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AE65C6B0005
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 16:26:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b64so7183829pfl.13
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 13:26:33 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p9sor878307pgr.366.2018.04.22.13.26.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Apr 2018 13:26:32 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [RFC PATCH 0/2] memory.low,min reclaim
Date: Sun, 22 Apr 2018 13:26:10 -0700
Message-Id: <20180422202612.127760-1-gthelen@google.com>
In-Reply-To: <20180320223353.5673-1-guro@fb.com>
References: <20180320223353.5673-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: guro@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, Cgroups <cgroups@vger.kernel.org>, kernel-team@fb.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Greg Thelen <gthelen@google.com>

Roman's previously posted memory.low,min patches add per memcg effective
low limit to detect overcommitment of parental limits.  But if we flip
low,min reclaim to bail if usage<{low,min} at any level, then we don't need
an effective low limit, which makes the code simpler.  When parent limits
are overcommited memory.min will oom kill, which is more drastic but makes
the memory.low a simpler concept.  If memcg a/b wants oom kill before
reclaim, then give it to them.  It seems a bit strange for a/b/memory.low's
behaviour to depend on a/c/memory.low (i.e. a/b.low is strong unless
a/b.low+a/c.low exceed a.low).

Previous patches:
- mm: rename page_counter's count/limit into usage/max
- mm: memory.low hierarchical behavior
- mm: treat memory.low value inclusive
- mm/docs: describe memory.low refinements
- mm: introduce memory.min
- mm: move the high field from struct mem_cgroup to page_counter
 8 files changed, 405 insertions(+), 141 deletions(-)

I think there might be a simpler way (ableit it doesn't yet include
Documentation):
- memcg: fix memory.low
- memcg: add memory.min
 3 files changed, 75 insertions(+), 6 deletions(-)

The idea of this alternate approach is for memory.low,min to avoid reclaim
if any portion of under-consideration memcg ancestry is under respective
limit.

Also, in either approach, I suspect we should mention the interaction with
numa contrainted allocations (cpuset.mems, mempolicy, mbind).  For example,
if a numa agnostic memcg with large memory.min happens to gobble up all of
node N1 memory, and a future task really wants node N1 memory (via
mempolicy) then we oom kill rather reclaim or migrating memory.
Ideas:
a) oom kill numa constrainted allocator, that's what we've been doing in
   Google.  I can provide patch if helpful.  I admit that it has
   shortcomings.
b) oom kill a memcg with memory.low protection if its TBD priority is lower
   than the allocating task.  Priority is a TBD concept.
c) consider migrating numa agnostic memory.low memory as a lighterweight
   alternative to oom kill.

I extended Roman's nifty reclaim test:
  #!/bin/bash
  #
  # Uppercase cgroups can tolerate some reclaim (current > low).
  # Lowerase cgroups are intolerate to reclaim (current < low).
  #
  #    A     A/memory.low = 2G, A/memory.current = 6G
  #  // \\
  # bC   De  b/memory.low = 3G  b/memory.current = 2G
  #          C/memory.low = 1G  C/memory.current = 2G
  #          D/memory.low = 0   D/memory.current = 2G
  #          e/memory.low = 10G e/memory.current = 0
  #
  #    F     F/memory.low = 2G, F/memory.current = 4G
  #   / \
  #  g   H   g/memory.low = 3G  g/memory.current = 2G
  #          H/memory.low = 1G  H/memory.current = 2G
  #
  #    i     i/memory.low = 5G, i/memory.current = 4G
  #   / \
  #  j   K   j/memory.low = 3G  j/memory.current = 2G
  #          K/memory.low = 1G  K/memory.current = 2G
  #
  #    L     L/memory.low = 2G, L/memory.current = 4G, L/memory.max = 4G
  #   / \
  #  m   N   m/memory.low = 3G  m/memory.current = 2G
  #          N/memory.low = 1G  N/memory.current = 2G
  #
  # setting memory.min: warmup => after global pressure
  # A    : 6306372k => 3154336k
  # A/b  : 2102184k => 2101928k
  # A/C  : 2101936k => 1048352k
  # A/D  : 2102252k => 4056k   
  # A/e  : 0k       => 0k      
  # F    : 4204420k => 3150272k
  # F/g  : 2102188k => 2101912k
  # F/H  : 2102232k => 1048360k
  # i    : 4204652k => 4203884k
  # i/j  : 2102324k => 2101940k
  # i/K  : 2102328k => 2101944k
  # L    : 4189976k => 3147824k
  # L/m  : 2101980k => 2101956k
  # L/N  : 2087996k => 1045868k
  #
  # setting memory.min: warmup => after L/m antagonist
  # A    : 6306076k => 6305988k
  # A/b  : 2102152k => 2102128k
  # A/C  : 2101948k => 2101916k
  # A/D  : 2101976k => 2101944k
  # A/e  : 0k       => 0k      
  # F    : 4204156k => 4203832k
  # F/g  : 2102220k => 2101920k
  # F/H  : 2101936k => 2101912k
  # i    : 4204204k => 4203852k
  # i/j  : 2102256k => 2101936k
  # i/K  : 2101948k => 2101916k
  # L    : 4190012k => 3886352k
  # L/m  : 2101996k => 2837856k
  # L/N  : 2088016k => 1048496k
  #
  # setting memory.low: warmup => after global pressure
  # A    : 6306220k => 3154864k
  # A/b  : 2101964k => 2101940k
  # A/C  : 2102204k => 1047040k
  # A/D  : 2102052k => 5884k	
  # A/e  : 0k       => 0k	
  # F    : 4204192k => 3147888k
  # F/g  : 2101948k => 2101916k
  # F/H  : 2102244k => 1045972k
  # i    : 4204480k => 4204056k
  # i/j  : 2102008k => 2101976k
  # i/K  : 2102464k => 2102080k
  # L    : 4190028k => 3150192k
  # L/m  : 2102004k => 2101980k
  # L/N  : 2088024k => 1048212k
  #
  # setting memory.low: warmup => after L/m antagonist
  # A    : 6306360k => 6305960k
  # A/b  : 2101988k => 2101924k
  # A/C  : 2102192k => 2101916k
  # A/D  : 2102180k => 2102120k
  # A/e  : 0k       => 0k	
  # F    : 4203964k => 4203908k
  # F/g  : 2102016k => 2101992k
  # F/H  : 2101948k => 2101916k
  # i    : 4204408k => 4203988k
  # i/j  : 2101984k => 2101936k
  # i/K  : 2102424k => 2102052k
  # L    : 4189960k => 3886296k
  # L/m  : 2101968k => 2838704k
  # L/N  : 2087992k => 1047592k

  set -o errexit
  set -o nounset
  set -o pipefail
  
  LIM="$1"; shift
  ANTAGONIST="$1"; shift
  CGPATH=/tmp/cgroup
  
  vmtouch2() {
    rm -f "$2"
    (echo $BASHPID > "${CGPATH}/$1/cgroup.procs" && exec /tmp/mmap --loop 1 --file "$2" "$3")
  }
  
  vmtouch() {
    # twice to ensure slab caches are warmed up and all objs are charged to cgroup.
    vmtouch2 "$1" "$2" "$3"
    vmtouch2 "$1" "$2" "$3"
  }
  
  dump() {
    for i in A A/b A/C A/D A/e F F/g F/H i i/j i/K L L/m L/N; do
      printf "%-5s: %sk\n" $i $(($(cat "${CGPATH}/${i}/memory.current")/1024))
    done
  }
  
  rm -f /file_?
  if [[ -e "${CGPATH}/A" ]]; then
    rmdir ${CGPATH}/?/? ${CGPATH}/?
  fi
  echo "+memory" > "${CGPATH}/cgroup.subtree_control"
  mkdir "${CGPATH}/A" "${CGPATH}/F" "${CGPATH}/i" "${CGPATH}/L"
  echo "+memory" > "${CGPATH}/A/cgroup.subtree_control"
  echo "+memory" > "${CGPATH}/F/cgroup.subtree_control"
  echo "+memory" > "${CGPATH}/i/cgroup.subtree_control"
  echo "+memory" > "${CGPATH}/L/cgroup.subtree_control"
  mkdir "${CGPATH}/A/b" "${CGPATH}/A/C" "${CGPATH}/A/D" "${CGPATH}/A/e"
  mkdir "${CGPATH}/F/g" "${CGPATH}/F/H"
  mkdir "${CGPATH}/i/j" "${CGPATH}/i/K"
  mkdir "${CGPATH}/L/m" "${CGPATH}/L/N"
  
  echo 2G > "${CGPATH}/A/memory.${LIM}"
  echo 3G > "${CGPATH}/A/b/memory.${LIM}"
  echo 1G > "${CGPATH}/A/C/memory.${LIM}"
  echo 0 > "${CGPATH}/A/D/memory.${LIM}"
  echo 10G > "${CGPATH}/A/e/memory.${LIM}"
  
  echo 2G > "${CGPATH}/F/memory.${LIM}"
  echo 3G > "${CGPATH}/F/g/memory.${LIM}"
  echo 1G > "${CGPATH}/F/H/memory.${LIM}"
  
  echo 5G > "${CGPATH}/i/memory.${LIM}"
  echo 3G > "${CGPATH}/i/j/memory.${LIM}"
  echo 1G > "${CGPATH}/i/K/memory.${LIM}"
  
  echo 2G > "${CGPATH}/L/memory.${LIM}"
  echo 4G > "${CGPATH}/L/memory.max"
  echo 3G > "${CGPATH}/L/m/memory.${LIM}"
  echo 1G > "${CGPATH}/L/N/memory.${LIM}"
  
  vmtouch A/b /file_b 2G
  vmtouch A/C /file_C 2G
  vmtouch A/D /file_D 2G
  
  vmtouch F/g /file_g 2G
  vmtouch F/H /file_H 2G
  
  vmtouch i/j /file_j 2G
  vmtouch i/K /file_K 2G
  
  vmtouch L/m /file_m 2G
  vmtouch L/N /file_N 2G
  
  vmtouch2 "$ANTAGONIST" /file_ant 150G
  echo
  echo "after $ANTAGONIST antagonist"
  dump
  
  rmdir "${CGPATH}/A/b" "${CGPATH}/A/C" "${CGPATH}/A/D" "${CGPATH}/A/e"
  rmdir "${CGPATH}/F/g" "${CGPATH}/F/H"
  rmdir "${CGPATH}/i/j" "${CGPATH}/i/K"
  rmdir "${CGPATH}/L/m" "${CGPATH}/L/N"
  rmdir "${CGPATH}/A" "${CGPATH}/F" "${CGPATH}/i" "${CGPATH}/L"
  rm /file_ant /file_b /file_C /file_D /file_g /file_H /file_j /file_K

Greg Thelen (2):
  memcg: fix memory.low
  memcg: add memory.min

 include/linux/memcontrol.h |  8 +++++
 mm/memcontrol.c            | 70 ++++++++++++++++++++++++++++++++++----
 mm/vmscan.c                |  3 ++
 3 files changed, 75 insertions(+), 6 deletions(-)

-- 
2.17.0.484.g0c8726318c-goog
